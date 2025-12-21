pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x499b11, uint256 _0x9d0f9c) external returns (bool);

    function _0x51dfe2(
        address from,
        address _0x499b11,
        uint256 _0x9d0f9c
    ) external returns (bool);

    function _0xa06390(address _0xf0912e) external view returns (uint256);

    function _0x32989e(address _0xfb79ab, uint256 _0x9d0f9c) external returns (bool);
}

contract ShezmuCollateralToken is IERC20 {
    string public _0x982a9e = "Shezmu Collateral Token";
    string public _0xc11eb8 = "SCT";
    uint8 public _0xd8479d = 18;

    mapping(address => uint256) public _0xa06390;
    mapping(address => mapping(address => uint256)) public _0xb8c8e9;
    uint256 public _0x61104e;

    function _0x794b6b(address _0x499b11, uint256 _0x9d0f9c) external {
        _0xa06390[_0x499b11] += _0x9d0f9c;
        _0x61104e += _0x9d0f9c;
    }

    function transfer(
        address _0x499b11,
        uint256 _0x9d0f9c
    ) external override returns (bool) {
        require(_0xa06390[msg.sender] >= _0x9d0f9c, "Insufficient balance");
        _0xa06390[msg.sender] -= _0x9d0f9c;
        _0xa06390[_0x499b11] += _0x9d0f9c;
        return true;
    }

    function _0x51dfe2(
        address from,
        address _0x499b11,
        uint256 _0x9d0f9c
    ) external override returns (bool) {
        require(_0xa06390[from] >= _0x9d0f9c, "Insufficient balance");
        require(
            _0xb8c8e9[from][msg.sender] >= _0x9d0f9c,
            "Insufficient allowance"
        );
        _0xa06390[from] -= _0x9d0f9c;
        _0xa06390[_0x499b11] += _0x9d0f9c;
        _0xb8c8e9[from][msg.sender] -= _0x9d0f9c;
        return true;
    }

    function _0x32989e(
        address _0xfb79ab,
        uint256 _0x9d0f9c
    ) external override returns (bool) {
        _0xb8c8e9[msg.sender][_0xfb79ab] = _0x9d0f9c;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public _0xd5f4c1;
    IERC20 public _0xa04d24;

    mapping(address => uint256) public _0x4c8ca7;
    mapping(address => uint256) public _0xba2fe9;

    uint256 public constant COLLATERAL_RATIO = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _0x4f90ee, address _0xacddba) {
        _0xd5f4c1 = IERC20(_0x4f90ee);
        _0xa04d24 = IERC20(_0xacddba);
    }

    function _0xff4a34(uint256 _0x9d0f9c) external {
        _0xd5f4c1._0x51dfe2(msg.sender, address(this), _0x9d0f9c);
        _0x4c8ca7[msg.sender] += _0x9d0f9c;
    }

    function _0xf41a08(uint256 _0x9d0f9c) external {
        uint256 _0x54109d = (_0x4c8ca7[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            _0xba2fe9[msg.sender] + _0x9d0f9c <= _0x54109d,
            "Insufficient collateral"
        );

        _0xba2fe9[msg.sender] += _0x9d0f9c;

        _0xa04d24.transfer(msg.sender, _0x9d0f9c);
    }

    function _0x8176da(uint256 _0x9d0f9c) external {
        require(_0xba2fe9[msg.sender] >= _0x9d0f9c, "Excessive repayment");
        _0xa04d24._0x51dfe2(msg.sender, address(this), _0x9d0f9c);
        _0xba2fe9[msg.sender] -= _0x9d0f9c;
    }

    function _0x146568(uint256 _0x9d0f9c) external {
        require(
            _0x4c8ca7[msg.sender] >= _0x9d0f9c,
            "Insufficient collateral"
        );
        uint256 _0x2a98bb = _0x4c8ca7[msg.sender] - _0x9d0f9c;
        uint256 _0x4211f9 = (_0x2a98bb * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            _0xba2fe9[msg.sender] <= _0x4211f9,
            "Would be undercollateralized"
        );

        _0x4c8ca7[msg.sender] -= _0x9d0f9c;
        _0xd5f4c1.transfer(msg.sender, _0x9d0f9c);
    }
}