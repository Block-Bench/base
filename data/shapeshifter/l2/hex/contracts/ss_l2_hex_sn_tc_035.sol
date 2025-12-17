// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x755ffe, uint256 _0x1ca703) external returns (bool);

    function _0x654e38(
        address from,
        address _0x755ffe,
        uint256 _0x1ca703
    ) external returns (bool);

    function _0xeea563(address _0x919100) external view returns (uint256);

    function _0x8054e9(address _0x007798, uint256 _0x1ca703) external returns (bool);
}

interface IERC721 {
    function _0x654e38(address from, address _0x755ffe, uint256 _0x34b0f8) external;

    function _0xd677d5(uint256 _0x34b0f8) external view returns (address);
}

contract WiseLending {
    struct PoolData {
        uint256 _0xbb8322;
        uint256 _0xce0c25;
        uint256 _0x071425;
        uint256 _0xcdaf8d;
    }

    mapping(address => PoolData) public _0x9a7970;
    mapping(uint256 => mapping(address => uint256)) public _0xa2263e;
    mapping(uint256 => mapping(address => uint256)) public _0xec9fa5;

    IERC721 public _0xb9a0b8;
    uint256 public _0x056b61;

    function _0xef0c5b() external returns (uint256) {
        uint256 _0x95505e = ++_0x056b61;
        return _0x95505e;
    }

    function _0x4da177(
        uint256 _0xefc8c2,
        address _0x6ad1ad,
        uint256 _0xe5da2c
    ) external returns (uint256 _0xdba823) {
        IERC20(_0x6ad1ad)._0x654e38(msg.sender, address(this), _0xe5da2c);

        PoolData storage _0xe23939 = _0x9a7970[_0x6ad1ad];

        if (_0xe23939._0xce0c25 == 0) {
            _0xdba823 = _0xe5da2c;
            _0xe23939._0xce0c25 = _0xe5da2c;
        } else {
            _0xdba823 =
                (_0xe5da2c * _0xe23939._0xce0c25) /
                _0xe23939._0xbb8322;
            _0xe23939._0xce0c25 += _0xdba823;
        }

        _0xe23939._0xbb8322 += _0xe5da2c;
        _0xa2263e[_0xefc8c2][_0x6ad1ad] += _0xdba823;

        return _0xdba823;
    }

    function _0xf8e985(
        uint256 _0xefc8c2,
        address _0x6ad1ad,
        uint256 _0x8784c4
    ) external returns (uint256 _0x2c9808) {
        require(
            _0xa2263e[_0xefc8c2][_0x6ad1ad] >= _0x8784c4,
            "Insufficient shares"
        );

        PoolData storage _0xe23939 = _0x9a7970[_0x6ad1ad];

        _0x2c9808 =
            (_0x8784c4 * _0xe23939._0xbb8322) /
            _0xe23939._0xce0c25;

        _0xa2263e[_0xefc8c2][_0x6ad1ad] -= _0x8784c4;
        _0xe23939._0xce0c25 -= _0x8784c4;
        _0xe23939._0xbb8322 -= _0x2c9808;

        IERC20(_0x6ad1ad).transfer(msg.sender, _0x2c9808);

        return _0x2c9808;
    }

    function _0x4378cc(
        uint256 _0xefc8c2,
        address _0x6ad1ad,
        uint256 _0x559183
    ) external returns (uint256 _0x1fb9de) {
        PoolData storage _0xe23939 = _0x9a7970[_0x6ad1ad];

        _0x1fb9de =
            (_0x559183 * _0xe23939._0xce0c25) /
            _0xe23939._0xbb8322;

        require(
            _0xa2263e[_0xefc8c2][_0x6ad1ad] >= _0x1fb9de,
            "Insufficient shares"
        );

        _0xa2263e[_0xefc8c2][_0x6ad1ad] -= _0x1fb9de;
        _0xe23939._0xce0c25 -= _0x1fb9de;
        _0xe23939._0xbb8322 -= _0x559183;

        IERC20(_0x6ad1ad).transfer(msg.sender, _0x559183);

        return _0x1fb9de;
    }

    function _0x9f1127(
        uint256 _0xefc8c2,
        address _0x6ad1ad
    ) external view returns (uint256) {
        return _0xa2263e[_0xefc8c2][_0x6ad1ad];
    }

    function _0x7ede52(address _0x6ad1ad) external view returns (uint256) {
        return _0x9a7970[_0x6ad1ad]._0xbb8322;
    }
}
