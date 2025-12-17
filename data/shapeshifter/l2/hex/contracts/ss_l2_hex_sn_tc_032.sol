// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xc7a8a1, uint256 _0xbf269c) external returns (bool);

    function _0xce115d(
        address from,
        address _0xc7a8a1,
        uint256 _0xbf269c
    ) external returns (bool);

    function _0xc97a1a(address _0xb84260) external view returns (uint256);

    function _0x6c411a(address _0xb7ffd3, uint256 _0xbf269c) external returns (bool);
}

interface IFlashLoanReceiver {
    function _0xd365bf(
        address[] calldata _0xd2c667,
        uint256[] calldata _0x7ac430,
        uint256[] calldata _0x9acb5a,
        address _0x233740,
        bytes calldata _0x78ac12
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 _0x9bc6be;
        uint256 _0x990a7d;
        address _0xe6a835;
    }

    mapping(address => ReserveData) public _0xfb6b0a;

    function _0x9f4d0a(
        address _0xea15f8,
        uint256 _0xbf269c,
        address _0xd1ea70,
        uint16 _0xd0a296
    ) external {
        IERC20(_0xea15f8)._0xce115d(msg.sender, address(this), _0xbf269c);

        ReserveData storage _0xdb07cb = _0xfb6b0a[_0xea15f8];

        uint256 _0x6e0698 = _0xdb07cb._0x9bc6be;
        if (_0x6e0698 == 0) {
            _0x6e0698 = RAY;
        }

        _0xdb07cb._0x9bc6be =
            _0x6e0698 +
            (_0xbf269c * RAY) /
            (_0xdb07cb._0x990a7d + 1);
        _0xdb07cb._0x990a7d += _0xbf269c;

        uint256 _0xf3ce11 = _0x29effb(_0xbf269c, _0xdb07cb._0x9bc6be);
        _0x2fc1ff(_0xdb07cb._0xe6a835, _0xd1ea70, _0xf3ce11);
    }

    function _0x215ca3(
        address _0xea15f8,
        uint256 _0xbf269c,
        address _0xc7a8a1
    ) external returns (uint256) {
        ReserveData storage _0xdb07cb = _0xfb6b0a[_0xea15f8];

        uint256 _0x400410 = _0x29effb(_0xbf269c, _0xdb07cb._0x9bc6be);

        _0xaa01cd(_0xdb07cb._0xe6a835, msg.sender, _0x400410);

        _0xdb07cb._0x990a7d -= _0xbf269c;
        IERC20(_0xea15f8).transfer(_0xc7a8a1, _0xbf269c);

        return _0xbf269c;
    }

    function _0x38a193(
        address _0xea15f8,
        uint256 _0xbf269c,
        uint256 _0xb59f18,
        uint16 _0xd0a296,
        address _0xd1ea70
    ) external {
        IERC20(_0xea15f8).transfer(_0xd1ea70, _0xbf269c);
    }

    function _0xa42baa(
        address _0x021f1d,
        address[] calldata _0xd2c667,
        uint256[] calldata _0x7ac430,
        uint256[] calldata _0xf58ed1,
        address _0xd1ea70,
        bytes calldata _0x78ac12,
        uint16 _0xd0a296
    ) external {
        for (uint256 i = 0; i < _0xd2c667.length; i++) {
            IERC20(_0xd2c667[i]).transfer(_0x021f1d, _0x7ac430[i]);
        }

        require(
            IFlashLoanReceiver(_0x021f1d)._0xd365bf(
                _0xd2c667,
                _0x7ac430,
                new uint256[](_0xd2c667.length),
                msg.sender,
                _0x78ac12
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < _0xd2c667.length; i++) {
            IERC20(_0xd2c667[i])._0xce115d(
                _0x021f1d,
                address(this),
                _0x7ac430[i]
            );
        }
    }

    function _0x29effb(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 _0x20d27a = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + _0x20d27a) / b;
    }

    function _0x2fc1ff(address _0x16a7e6, address _0xc7a8a1, uint256 _0xbf269c) internal {}

    function _0xaa01cd(
        address _0x16a7e6,
        address from,
        uint256 _0xbf269c
    ) internal {}
}
