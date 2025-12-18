// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x612ad3, uint256 _0x9a3b00) external returns (bool);

    function _0x15117a(
        address from,
        address _0x612ad3,
        uint256 _0x9a3b00
    ) external returns (bool);

    function _0xe54be7(address _0xc6abd5) external view returns (uint256);

    function _0x40990e(address _0x2dba72, uint256 _0x9a3b00) external returns (bool);
}

contract ShezmuCollateralToken is IERC20 {
    string public _0x8d03a5 = "Shezmu Collateral Token";
    string public _0xf76a6c = "SCT";
    uint8 public _0x6466cf = 18;

    mapping(address => uint256) public _0xe54be7;
    mapping(address => mapping(address => uint256)) public _0x7e3169;
    uint256 public _0x1cf35c;

    function _0xa570da(address _0x612ad3, uint256 _0x9a3b00) external {
        _0xe54be7[_0x612ad3] += _0x9a3b00;
        _0x1cf35c += _0x9a3b00;
    }

    function transfer(
        address _0x612ad3,
        uint256 _0x9a3b00
    ) external override returns (bool) {
        require(_0xe54be7[msg.sender] >= _0x9a3b00, "Insufficient balance");
        _0xe54be7[msg.sender] -= _0x9a3b00;
        _0xe54be7[_0x612ad3] += _0x9a3b00;
        return true;
    }

    function _0x15117a(
        address from,
        address _0x612ad3,
        uint256 _0x9a3b00
    ) external override returns (bool) {
        require(_0xe54be7[from] >= _0x9a3b00, "Insufficient balance");
        require(
            _0x7e3169[from][msg.sender] >= _0x9a3b00,
            "Insufficient allowance"
        );
        _0xe54be7[from] -= _0x9a3b00;
        _0xe54be7[_0x612ad3] += _0x9a3b00;
        _0x7e3169[from][msg.sender] -= _0x9a3b00;
        return true;
    }

    function _0x40990e(
        address _0x2dba72,
        uint256 _0x9a3b00
    ) external override returns (bool) {
        _0x7e3169[msg.sender][_0x2dba72] = _0x9a3b00;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public _0x3fd10b;
    IERC20 public _0x8c3ef7;

    mapping(address => uint256) public _0xb262e4;
    mapping(address => uint256) public _0x9add9d;

    uint256 public constant COLLATERAL_RATIO = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _0x77bb1b, address _0xba86c6) {
        _0x3fd10b = IERC20(_0x77bb1b);
        _0x8c3ef7 = IERC20(_0xba86c6);
    }

    function _0x234224(uint256 _0x9a3b00) external {
        _0x3fd10b._0x15117a(msg.sender, address(this), _0x9a3b00);
        _0xb262e4[msg.sender] += _0x9a3b00;
    }

    function _0xd427be(uint256 _0x9a3b00) external {
        uint256 _0xa265be = (_0xb262e4[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            _0x9add9d[msg.sender] + _0x9a3b00 <= _0xa265be,
            "Insufficient collateral"
        );

        _0x9add9d[msg.sender] += _0x9a3b00;

        _0x8c3ef7.transfer(msg.sender, _0x9a3b00);
    }

    function _0x8b086f(uint256 _0x9a3b00) external {
        require(_0x9add9d[msg.sender] >= _0x9a3b00, "Excessive repayment");
        _0x8c3ef7._0x15117a(msg.sender, address(this), _0x9a3b00);
        _0x9add9d[msg.sender] -= _0x9a3b00;
    }

    function _0xdca724(uint256 _0x9a3b00) external {
        require(
            _0xb262e4[msg.sender] >= _0x9a3b00,
            "Insufficient collateral"
        );
        uint256 _0x9f5157 = _0xb262e4[msg.sender] - _0x9a3b00;
        uint256 _0x705d69 = (_0x9f5157 * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            _0x9add9d[msg.sender] <= _0x705d69,
            "Would be undercollateralized"
        );

        _0xb262e4[msg.sender] -= _0x9a3b00;
        _0x3fd10b.transfer(msg.sender, _0x9a3b00);
    }
}
