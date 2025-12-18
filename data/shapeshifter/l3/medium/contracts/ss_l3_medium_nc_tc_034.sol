pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x9e0ae1, uint256 _0x73fbf2) external returns (bool);

    function _0xa8809b(
        address from,
        address _0x9e0ae1,
        uint256 _0x73fbf2
    ) external returns (bool);

    function _0xe47654(address _0xe100bf) external view returns (uint256);

    function _0x4c503b(address _0xb45e7e, uint256 _0x73fbf2) external returns (bool);
}

interface IUniswapV3Pool {
    function _0xeae6a8(
        address _0xbc0e8a,
        bool _0x56ea91,
        int256 _0x2df6aa,
        uint160 _0x0d5a66,
        bytes calldata data
    ) external returns (int256 _0x712be0, int256 _0x68a5b0);

    function _0xaf77f6(
        address _0xbc0e8a,
        uint256 _0x712be0,
        uint256 _0x68a5b0,
        bytes calldata data
    ) external;
}

contract GammaHypervisor {
    IERC20 public _0x4ed10d;
    IERC20 public _0x474b90;
    IUniswapV3Pool public _0x608da8;

    uint256 public _0x27cd1e;
    mapping(address => uint256) public _0xe47654;

    struct Position {
        uint128 _0x94c6ee;
        int24 _0x43daf5;
        int24 _0x180595;
    }

    Position public _0x43c33e;
    Position public _0x17714c;

    function _0xffd870(
        uint256 _0xfc987e,
        uint256 _0x3fcf27,
        address _0x9e0ae1
    ) external returns (uint256 _0xff7b61) {
        uint256 _0xb5c2e3 = _0x4ed10d._0xe47654(address(this));
        uint256 _0x543e9e = _0x474b90._0xe47654(address(this));

        _0x4ed10d._0xa8809b(msg.sender, address(this), _0xfc987e);
        _0x474b90._0xa8809b(msg.sender, address(this), _0x3fcf27);

        if (_0x27cd1e == 0) {
            _0xff7b61 = _0xfc987e + _0x3fcf27;
        } else {
            uint256 _0x20caf4 = _0xb5c2e3 + _0xfc987e;
            uint256 _0xa6a038 = _0x543e9e + _0x3fcf27;

            _0xff7b61 = (_0x27cd1e * (_0xfc987e + _0x3fcf27)) / (_0xb5c2e3 + _0x543e9e);
        }

        _0xe47654[_0x9e0ae1] += _0xff7b61;
        _0x27cd1e += _0xff7b61;

        _0x3ad486(_0xfc987e, _0x3fcf27);
    }

    function _0xe3724b(
        uint256 _0xff7b61,
        address _0x9e0ae1
    ) external returns (uint256 _0x712be0, uint256 _0x68a5b0) {
        require(_0xe47654[msg.sender] >= _0xff7b61, "Insufficient balance");

        uint256 _0xb5c2e3 = _0x4ed10d._0xe47654(address(this));
        uint256 _0x543e9e = _0x474b90._0xe47654(address(this));

        _0x712be0 = (_0xff7b61 * _0xb5c2e3) / _0x27cd1e;
        _0x68a5b0 = (_0xff7b61 * _0x543e9e) / _0x27cd1e;

        _0xe47654[msg.sender] -= _0xff7b61;
        _0x27cd1e -= _0xff7b61;

        _0x4ed10d.transfer(_0x9e0ae1, _0x712be0);
        _0x474b90.transfer(_0x9e0ae1, _0x68a5b0);
    }

    function _0xb9bdb8() external {
        _0xafe18a(_0x43c33e._0x94c6ee);

        _0x3ad486(
            _0x4ed10d._0xe47654(address(this)),
            _0x474b90._0xe47654(address(this))
        );
    }

    function _0x3ad486(uint256 _0x712be0, uint256 _0x68a5b0) internal {}

    function _0xafe18a(uint128 _0x94c6ee) internal {}
}