pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x9f0167, uint256 _0x2ad154) external returns (bool);

    function _0x94490b(
        address from,
        address _0x9f0167,
        uint256 _0x2ad154
    ) external returns (bool);

    function _0xb795ed(address _0xd65fae) external view returns (uint256);

    function _0x5403df(address _0xb34f12, uint256 _0x2ad154) external returns (bool);
}

interface IERC721 {
    function _0x94490b(address from, address _0x9f0167, uint256 _0x3396f3) external;

    function _0x8ad118(uint256 _0x3396f3) external view returns (address);
}

contract WiseLending {
    struct PoolData {
        uint256 _0x3ed264;
        uint256 _0xc047b1;
        uint256 _0x0aef25;
        uint256 _0x20ad97;
    }

    mapping(address => PoolData) public _0x77f8ca;
    mapping(uint256 => mapping(address => uint256)) public _0xef385b;
    mapping(uint256 => mapping(address => uint256)) public _0x569da4;

    IERC721 public _0x405b12;
    uint256 public _0xa6f1c4;

    function _0x3a258f() external returns (uint256) {
        uint256 _0x23fa22 = ++_0xa6f1c4;
        return _0x23fa22;
    }

    function _0x6bc443(
        uint256 _0x3374ae,
        address _0x9d19cc,
        uint256 _0x7b0238
    ) external returns (uint256 _0x7b915d) {
        IERC20(_0x9d19cc)._0x94490b(msg.sender, address(this), _0x7b0238);

        PoolData storage _0xbd6886 = _0x77f8ca[_0x9d19cc];

        if (_0xbd6886._0xc047b1 == 0) {
            _0x7b915d = _0x7b0238;
            _0xbd6886._0xc047b1 = _0x7b0238;
        } else {
            _0x7b915d =
                (_0x7b0238 * _0xbd6886._0xc047b1) /
                _0xbd6886._0x3ed264;
            _0xbd6886._0xc047b1 += _0x7b915d;
        }

        _0xbd6886._0x3ed264 += _0x7b0238;
        _0xef385b[_0x3374ae][_0x9d19cc] += _0x7b915d;

        return _0x7b915d;
    }

    function _0xc3731c(
        uint256 _0x3374ae,
        address _0x9d19cc,
        uint256 _0x42119a
    ) external returns (uint256 _0x470dbb) {
        require(
            _0xef385b[_0x3374ae][_0x9d19cc] >= _0x42119a,
            "Insufficient shares"
        );

        PoolData storage _0xbd6886 = _0x77f8ca[_0x9d19cc];

        _0x470dbb =
            (_0x42119a * _0xbd6886._0x3ed264) /
            _0xbd6886._0xc047b1;

        _0xef385b[_0x3374ae][_0x9d19cc] -= _0x42119a;
        _0xbd6886._0xc047b1 -= _0x42119a;
        _0xbd6886._0x3ed264 -= _0x470dbb;

        IERC20(_0x9d19cc).transfer(msg.sender, _0x470dbb);

        return _0x470dbb;
    }

    function _0xdf668e(
        uint256 _0x3374ae,
        address _0x9d19cc,
        uint256 _0x402306
    ) external returns (uint256 _0x55c009) {
        PoolData storage _0xbd6886 = _0x77f8ca[_0x9d19cc];

        _0x55c009 =
            (_0x402306 * _0xbd6886._0xc047b1) /
            _0xbd6886._0x3ed264;

        require(
            _0xef385b[_0x3374ae][_0x9d19cc] >= _0x55c009,
            "Insufficient shares"
        );

        _0xef385b[_0x3374ae][_0x9d19cc] -= _0x55c009;
        _0xbd6886._0xc047b1 -= _0x55c009;
        _0xbd6886._0x3ed264 -= _0x402306;

        IERC20(_0x9d19cc).transfer(msg.sender, _0x402306);

        return _0x55c009;
    }

    function _0x930e54(
        uint256 _0x3374ae,
        address _0x9d19cc
    ) external view returns (uint256) {
        return _0xef385b[_0x3374ae][_0x9d19cc];
    }

    function _0x45b15d(address _0x9d19cc) external view returns (uint256) {
        return _0x77f8ca[_0x9d19cc]._0x3ed264;
    }
}