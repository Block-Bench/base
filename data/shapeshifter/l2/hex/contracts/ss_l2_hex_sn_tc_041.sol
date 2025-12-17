// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xaa12f5, uint256 _0xe8a2da) external returns (bool);

    function _0x5dfe07(
        address from,
        address _0xaa12f5,
        uint256 _0xe8a2da
    ) external returns (bool);

    function _0x000c03(address _0x6673a1) external view returns (uint256);

    function _0x68afd9(address _0x378611, uint256 _0xe8a2da) external returns (bool);
}

contract ShezmuCollateralToken is IERC20 {
    string public _0x12207b = "Shezmu Collateral Token";
    string public _0x47a8ac = "SCT";
    uint8 public _0x4f58dd = 18;

    mapping(address => uint256) public _0x000c03;
    mapping(address => mapping(address => uint256)) public _0xcb2bee;
    uint256 public _0xaffb48;

    function _0x5546ae(address _0xaa12f5, uint256 _0xe8a2da) external {
        _0x000c03[_0xaa12f5] += _0xe8a2da;
        _0xaffb48 += _0xe8a2da;
    }

    function transfer(
        address _0xaa12f5,
        uint256 _0xe8a2da
    ) external override returns (bool) {
        require(_0x000c03[msg.sender] >= _0xe8a2da, "Insufficient balance");
        _0x000c03[msg.sender] -= _0xe8a2da;
        _0x000c03[_0xaa12f5] += _0xe8a2da;
        return true;
    }

    function _0x5dfe07(
        address from,
        address _0xaa12f5,
        uint256 _0xe8a2da
    ) external override returns (bool) {
        require(_0x000c03[from] >= _0xe8a2da, "Insufficient balance");
        require(
            _0xcb2bee[from][msg.sender] >= _0xe8a2da,
            "Insufficient allowance"
        );
        _0x000c03[from] -= _0xe8a2da;
        _0x000c03[_0xaa12f5] += _0xe8a2da;
        _0xcb2bee[from][msg.sender] -= _0xe8a2da;
        return true;
    }

    function _0x68afd9(
        address _0x378611,
        uint256 _0xe8a2da
    ) external override returns (bool) {
        _0xcb2bee[msg.sender][_0x378611] = _0xe8a2da;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public _0x6e0d93;
    IERC20 public _0x6d1bc5;

    mapping(address => uint256) public _0x6d6249;
    mapping(address => uint256) public _0xcad63b;

    uint256 public constant COLLATERAL_RATIO = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _0x49e184, address _0x4927d2) {
        _0x6e0d93 = IERC20(_0x49e184);
        _0x6d1bc5 = IERC20(_0x4927d2);
    }

    function _0x93c9e7(uint256 _0xe8a2da) external {
        _0x6e0d93._0x5dfe07(msg.sender, address(this), _0xe8a2da);
        _0x6d6249[msg.sender] += _0xe8a2da;
    }

    function _0x48fcc3(uint256 _0xe8a2da) external {
        uint256 _0x09eac0 = (_0x6d6249[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            _0xcad63b[msg.sender] + _0xe8a2da <= _0x09eac0,
            "Insufficient collateral"
        );

        _0xcad63b[msg.sender] += _0xe8a2da;

        _0x6d1bc5.transfer(msg.sender, _0xe8a2da);
    }

    function _0x4f15e7(uint256 _0xe8a2da) external {
        require(_0xcad63b[msg.sender] >= _0xe8a2da, "Excessive repayment");
        _0x6d1bc5._0x5dfe07(msg.sender, address(this), _0xe8a2da);
        _0xcad63b[msg.sender] -= _0xe8a2da;
    }

    function _0x8a5000(uint256 _0xe8a2da) external {
        require(
            _0x6d6249[msg.sender] >= _0xe8a2da,
            "Insufficient collateral"
        );
        uint256 _0x9a20c4 = _0x6d6249[msg.sender] - _0xe8a2da;
        uint256 _0x7c571d = (_0x9a20c4 * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            _0xcad63b[msg.sender] <= _0x7c571d,
            "Would be undercollateralized"
        );

        _0x6d6249[msg.sender] -= _0xe8a2da;
        _0x6e0d93.transfer(msg.sender, _0xe8a2da);
    }
}
