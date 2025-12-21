pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xb98cac, uint256 _0x72750c) external returns (bool);

    function _0x1ce170(
        address from,
        address _0xb98cac,
        uint256 _0x72750c
    ) external returns (bool);

    function _0x1a023b(address _0xbacc2e) external view returns (uint256);

    function _0x23fa56(address _0xb40e95, uint256 _0x72750c) external returns (bool);
}

interface IUniswapV3Pool {
    function _0xf20a8e(
        address _0x4315f3,
        bool _0xc4e1fa,
        int256 _0x8d7682,
        uint160 _0x0e14e0,
        bytes calldata data
    ) external returns (int256 _0xc03b52, int256 _0x3419fe);

    function _0x0bb3aa(
        address _0x4315f3,
        uint256 _0xc03b52,
        uint256 _0x3419fe,
        bytes calldata data
    ) external;
}

contract GammaHypervisor {
    IERC20 public _0xb12a38;
    IERC20 public _0x2da900;
    IUniswapV3Pool public _0x9517a4;

    uint256 public _0x9d2dbd;
    mapping(address => uint256) public _0x1a023b;

    struct Position {
        uint128 _0x32e48f;
        int24 _0x8119b0;
        int24 _0x2dc752;
    }

    Position public _0xf11950;
    Position public _0xc391c1;

    function _0xff1673(
        uint256 _0x75e891,
        uint256 _0x286f8d,
        address _0xb98cac
    ) external returns (uint256 _0x08ee4c) {
        uint256 _0xe1b4fe = _0xb12a38._0x1a023b(address(this));
        uint256 _0xf19413 = _0x2da900._0x1a023b(address(this));

        _0xb12a38._0x1ce170(msg.sender, address(this), _0x75e891);
        _0x2da900._0x1ce170(msg.sender, address(this), _0x286f8d);

        if (_0x9d2dbd == 0) {
            _0x08ee4c = _0x75e891 + _0x286f8d;
        } else {
            uint256 _0xda7b56 = _0xe1b4fe + _0x75e891;
            uint256 _0xb7fbb7 = _0xf19413 + _0x286f8d;

            _0x08ee4c = (_0x9d2dbd * (_0x75e891 + _0x286f8d)) / (_0xe1b4fe + _0xf19413);
        }

        _0x1a023b[_0xb98cac] += _0x08ee4c;
        _0x9d2dbd += _0x08ee4c;

        _0xaea8c0(_0x75e891, _0x286f8d);
    }

    function _0xa87814(
        uint256 _0x08ee4c,
        address _0xb98cac
    ) external returns (uint256 _0xc03b52, uint256 _0x3419fe) {
        require(_0x1a023b[msg.sender] >= _0x08ee4c, "Insufficient balance");

        uint256 _0xe1b4fe = _0xb12a38._0x1a023b(address(this));
        uint256 _0xf19413 = _0x2da900._0x1a023b(address(this));

        _0xc03b52 = (_0x08ee4c * _0xe1b4fe) / _0x9d2dbd;
        _0x3419fe = (_0x08ee4c * _0xf19413) / _0x9d2dbd;

        _0x1a023b[msg.sender] -= _0x08ee4c;
        _0x9d2dbd -= _0x08ee4c;

        _0xb12a38.transfer(_0xb98cac, _0xc03b52);
        _0x2da900.transfer(_0xb98cac, _0x3419fe);
    }

    function _0x5f4c5a() external {
        _0xa4f8a0(_0xf11950._0x32e48f);

        _0xaea8c0(
            _0xb12a38._0x1a023b(address(this)),
            _0x2da900._0x1a023b(address(this))
        );
    }

    function _0xaea8c0(uint256 _0xc03b52, uint256 _0x3419fe) internal {}

    function _0xa4f8a0(uint128 _0x32e48f) internal {}
}