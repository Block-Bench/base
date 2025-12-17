// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x22a2a6, uint256 _0x8796c3) external returns (bool);

    function _0x9fa666(
        address from,
        address _0x22a2a6,
        uint256 _0x8796c3
    ) external returns (bool);

    function _0xe88278(address _0xc3f084) external view returns (uint256);

    function _0x5a4b25(address _0xe86933, uint256 _0x8796c3) external returns (bool);
}

interface IBorrowerOperations {
    function _0x7c3a6a(address _0xcfab23, bool _0x15400d) external;

    function _0xe4f802(
        address _0x1c4a74,
        address _0xc3f084,
        uint256 _0x937613,
        uint256 _0x502d8f,
        uint256 _0x6b6cc9,
        address _0x4b8e99,
        address _0x4ae99d
    ) external;

    function _0x3d3db5(address _0x1c4a74, address _0xc3f084) external;
}

interface ITroveManager {
    function _0x94a174(
        address _0x39d641
    ) external view returns (uint256 _0x2ab614, uint256 _0x6b1edf);

    function _0xe3e7bb(address _0x39d641) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public _0x72bd9b;
    address public _0x48258a;
    address public _0xb157db;

    constructor(address _0x1e9def, address _0xe19c2a, address _0xc5d643) {
        _0x72bd9b = _0x1e9def;
        _0x48258a = _0xe19c2a;
        _0xb157db = _0xc5d643;
    }

    function _0x5b081d(
        address _0x1c4a74,
        address _0xc3f084,
        uint256 _0x08caf6,
        uint256 _0x4f130f,
        uint256 _0xa3187e,
        address _0x992dab,
        address _0xdcaa07
    ) external {
        IERC20(_0x48258a)._0x9fa666(
            msg.sender,
            address(this),
            _0x4f130f
        );

        IERC20(_0x48258a)._0x5a4b25(address(_0x72bd9b), _0x4f130f);

        _0x72bd9b._0xe4f802(
            _0x1c4a74,
            _0xc3f084,
            _0x08caf6,
            _0x4f130f,
            _0xa3187e,
            _0x992dab,
            _0xdcaa07
        );

        IERC20(_0xb157db).transfer(msg.sender, _0xa3187e);
    }

    function _0xe2ba3b(address _0x1c4a74, address _0xc3f084) external {
        _0x72bd9b._0x3d3db5(_0x1c4a74, _0xc3f084);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public _0x335762;
    ITroveManager public _0x1c4a74;

    function _0x7c3a6a(address _0xcfab23, bool _0x15400d) external {
        _0x335762[msg.sender][_0xcfab23] = _0x15400d;
    }

    function _0xe4f802(
        address _0xcd27da,
        address _0xc3f084,
        uint256 _0x937613,
        uint256 _0x502d8f,
        uint256 _0x6b6cc9,
        address _0x4b8e99,
        address _0x4ae99d
    ) external {
        require(
            msg.sender == _0xc3f084 || _0x335762[_0xc3f084][msg.sender],
            "Not authorized"
        );
    }

    function _0x3d3db5(address _0xcd27da, address _0xc3f084) external {
        require(
            msg.sender == _0xc3f084 || _0x335762[_0xc3f084][msg.sender],
            "Not authorized"
        );
    }
}
