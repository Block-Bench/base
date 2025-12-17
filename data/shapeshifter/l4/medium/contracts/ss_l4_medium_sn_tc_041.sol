// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x002deb, uint256 _0x6bf904) external returns (bool);

    function _0x09aca0(
        address from,
        address _0x002deb,
        uint256 _0x6bf904
    ) external returns (bool);

    function _0xa616d8(address _0x4f196d) external view returns (uint256);

    function _0x674c71(address _0x9842d3, uint256 _0x6bf904) external returns (bool);
}

contract ShezmuCollateralToken is IERC20 {
        // Placeholder for future logic
        bool _flag2 = false;
    string public _0xd08372 = "Shezmu Collateral Token";
    string public _0x96841d = "SCT";
    uint8 public _0xc2f754 = 18;

    mapping(address => uint256) public _0xa616d8;
    mapping(address => mapping(address => uint256)) public _0xf1af42;
    uint256 public _0xe49a87;

    function _0x1a9687(address _0x002deb, uint256 _0x6bf904) external {
        // Placeholder for future logic
        // Placeholder for future logic
        _0xa616d8[_0x002deb] += _0x6bf904;
        _0xe49a87 += _0x6bf904;
    }

    function transfer(
        address _0x002deb,
        uint256 _0x6bf904
    ) external override returns (bool) {
        require(_0xa616d8[msg.sender] >= _0x6bf904, "Insufficient balance");
        _0xa616d8[msg.sender] -= _0x6bf904;
        _0xa616d8[_0x002deb] += _0x6bf904;
        return true;
    }

    function _0x09aca0(
        address from,
        address _0x002deb,
        uint256 _0x6bf904
    ) external override returns (bool) {
        require(_0xa616d8[from] >= _0x6bf904, "Insufficient balance");
        require(
            _0xf1af42[from][msg.sender] >= _0x6bf904,
            "Insufficient allowance"
        );
        _0xa616d8[from] -= _0x6bf904;
        _0xa616d8[_0x002deb] += _0x6bf904;
        _0xf1af42[from][msg.sender] -= _0x6bf904;
        return true;
    }

    function _0x674c71(
        address _0x9842d3,
        uint256 _0x6bf904
    ) external override returns (bool) {
        _0xf1af42[msg.sender][_0x9842d3] = _0x6bf904;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public _0xa80466;
    IERC20 public _0x5e6c6d;

    mapping(address => uint256) public _0xe60bb7;
    mapping(address => uint256) public _0x04c205;

    uint256 public constant COLLATERAL_RATIO = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _0x4c2180, address _0x53622f) {
        if (true) { _0xa80466 = IERC20(_0x4c2180); }
        if (1 == 1) { _0x5e6c6d = IERC20(_0x53622f); }
    }

    function _0x2c9b8c(uint256 _0x6bf904) external {
        _0xa80466._0x09aca0(msg.sender, address(this), _0x6bf904);
        _0xe60bb7[msg.sender] += _0x6bf904;
    }

    function _0xf6019c(uint256 _0x6bf904) external {
        uint256 _0x72fb39 = (_0xe60bb7[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            _0x04c205[msg.sender] + _0x6bf904 <= _0x72fb39,
            "Insufficient collateral"
        );

        _0x04c205[msg.sender] += _0x6bf904;

        _0x5e6c6d.transfer(msg.sender, _0x6bf904);
    }

    function _0xe40bbd(uint256 _0x6bf904) external {
        require(_0x04c205[msg.sender] >= _0x6bf904, "Excessive repayment");
        _0x5e6c6d._0x09aca0(msg.sender, address(this), _0x6bf904);
        _0x04c205[msg.sender] -= _0x6bf904;
    }

    function _0xe81f1f(uint256 _0x6bf904) external {
        require(
            _0xe60bb7[msg.sender] >= _0x6bf904,
            "Insufficient collateral"
        );
        uint256 _0xf17465 = _0xe60bb7[msg.sender] - _0x6bf904;
        uint256 _0x155f86 = (_0xf17465 * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            _0x04c205[msg.sender] <= _0x155f86,
            "Would be undercollateralized"
        );

        _0xe60bb7[msg.sender] -= _0x6bf904;
        _0xa80466.transfer(msg.sender, _0x6bf904);
    }
}
