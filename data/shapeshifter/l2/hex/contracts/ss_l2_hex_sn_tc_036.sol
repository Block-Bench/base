// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x26843f, uint256 _0xcddc7f) external returns (bool);

    function _0xe83e6d(
        address from,
        address _0x26843f,
        uint256 _0xcddc7f
    ) external returns (bool);

    function _0x7340f7(address _0x083535) external view returns (uint256);

    function _0x59c8d3(address _0x317a81, uint256 _0xcddc7f) external returns (bool);
}

interface IBorrowerOperations {
    function _0x8341d2(address _0x10ecf2, bool _0x7d086e) external;

    function _0xecf919(
        address _0x95b2ff,
        address _0x083535,
        uint256 _0x55d667,
        uint256 _0x962aae,
        uint256 _0xeaa9fa,
        address _0xe7d533,
        address _0xc0ca59
    ) external;

    function _0xb7331d(address _0x95b2ff, address _0x083535) external;
}

interface ITroveManager {
    function _0x083182(
        address _0x32c60d
    ) external view returns (uint256 _0xdf865f, uint256 _0x480977);

    function _0xe5972b(address _0x32c60d) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public _0xcb05c3;
    address public _0xf4a13c;
    address public _0xc29f68;

    constructor(address _0x30d9a9, address _0xb38df6, address _0xd7119f) {
        _0xcb05c3 = _0x30d9a9;
        _0xf4a13c = _0xb38df6;
        _0xc29f68 = _0xd7119f;
    }

    function _0x62acea(
        address _0x95b2ff,
        address _0x083535,
        uint256 _0xcee0ac,
        uint256 _0x572301,
        uint256 _0x66d12a,
        address _0xf8264b,
        address _0x0a0da2
    ) external {
        IERC20(_0xf4a13c)._0xe83e6d(
            msg.sender,
            address(this),
            _0x572301
        );

        IERC20(_0xf4a13c)._0x59c8d3(address(_0xcb05c3), _0x572301);

        _0xcb05c3._0xecf919(
            _0x95b2ff,
            _0x083535,
            _0xcee0ac,
            _0x572301,
            _0x66d12a,
            _0xf8264b,
            _0x0a0da2
        );

        IERC20(_0xc29f68).transfer(msg.sender, _0x66d12a);
    }

    function _0x746921(address _0x95b2ff, address _0x083535) external {
        _0xcb05c3._0xb7331d(_0x95b2ff, _0x083535);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public _0x1e7b20;
    ITroveManager public _0x95b2ff;

    function _0x8341d2(address _0x10ecf2, bool _0x7d086e) external {
        _0x1e7b20[msg.sender][_0x10ecf2] = _0x7d086e;
    }

    function _0xecf919(
        address _0x1bb5e5,
        address _0x083535,
        uint256 _0x55d667,
        uint256 _0x962aae,
        uint256 _0xeaa9fa,
        address _0xe7d533,
        address _0xc0ca59
    ) external {
        require(
            msg.sender == _0x083535 || _0x1e7b20[_0x083535][msg.sender],
            "Not authorized"
        );
    }

    function _0xb7331d(address _0x1bb5e5, address _0x083535) external {
        require(
            msg.sender == _0x083535 || _0x1e7b20[_0x083535][msg.sender],
            "Not authorized"
        );
    }
}
