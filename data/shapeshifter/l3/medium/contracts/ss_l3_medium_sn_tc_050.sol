// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x8ba85b, uint256 _0xc1c3d2) external returns (bool);

    function _0xb88703(
        address from,
        address _0x8ba85b,
        uint256 _0xc1c3d2
    ) external returns (bool);

    function _0xfd05ec(address _0x4f3255) external view returns (uint256);
}

contract MunchablesLockManager {
    address public _0xa2aba3;
    address public _0xc8fa8f;

    struct PlayerSettings {
        uint256 _0x7a4ef4;
        address _0xe17c02;
        uint256 _0x3792f5;
        uint256 _0x62ef99;
    }

    mapping(address => PlayerSettings) public _0x1faf1c;
    mapping(address => uint256) public _0x8c07ca;

    IERC20 public immutable _0xe3bec4;

    event Locked(address _0x95d81a, uint256 _0xc1c3d2, address _0xbc3bf6);
    event ConfigUpdated(address _0xe38453, address _0x2a949e);

    constructor(address _0x9911ba) {
        _0xa2aba3 = msg.sender;
        _0xe3bec4 = IERC20(_0x9911ba);
    }

    modifier _0xc90f83() {
        require(msg.sender == _0xa2aba3, "Not admin");
        _;
    }

    function _0xb7d7cf(uint256 _0xc1c3d2, uint256 _0xb16d38) external {
        require(_0xc1c3d2 > 0, "Zero amount");

        _0xe3bec4._0xb88703(msg.sender, address(this), _0xc1c3d2);

        _0x8c07ca[msg.sender] += _0xc1c3d2;
        _0x1faf1c[msg.sender] = PlayerSettings({
            _0x7a4ef4: _0xc1c3d2,
            _0xe17c02: msg.sender,
            _0x3792f5: _0xb16d38,
            _0x62ef99: block.timestamp
        });

        emit Locked(msg.sender, _0xc1c3d2, msg.sender);
    }

    function _0x9939f4(address _0x05dd60) external _0xc90f83 {
        address _0xe38453 = _0xc8fa8f;
        _0xc8fa8f = _0x05dd60;

        emit ConfigUpdated(_0xe38453, _0x05dd60);
    }

    function _0x825e61(
        address _0x95d81a,
        address _0xa50cff
    ) external _0xc90f83 {
        _0x1faf1c[_0x95d81a]._0xe17c02 = _0xa50cff;
    }

    function _0xd22013() external {
        PlayerSettings memory _0x4cfe2b = _0x1faf1c[msg.sender];

        require(_0x4cfe2b._0x7a4ef4 > 0, "No locked tokens");
        require(
            block.timestamp >= _0x4cfe2b._0x62ef99 + _0x4cfe2b._0x3792f5,
            "Still locked"
        );

        uint256 _0xc1c3d2 = _0x4cfe2b._0x7a4ef4;

        address _0xbc3bf6 = _0x4cfe2b._0xe17c02;

        delete _0x1faf1c[msg.sender];
        _0x8c07ca[msg.sender] = 0;

        _0xe3bec4.transfer(_0xbc3bf6, _0xc1c3d2);
    }

    function _0x2c72e4(address _0x95d81a) external _0xc90f83 {
        PlayerSettings memory _0x4cfe2b = _0x1faf1c[_0x95d81a];
        uint256 _0xc1c3d2 = _0x4cfe2b._0x7a4ef4;
        address _0xbc3bf6 = _0x4cfe2b._0xe17c02;

        delete _0x1faf1c[_0x95d81a];
        _0x8c07ca[_0x95d81a] = 0;

        _0xe3bec4.transfer(_0xbc3bf6, _0xc1c3d2);
    }

    function _0x6d1943(address _0xa51f37) external _0xc90f83 {
        _0xa2aba3 = _0xa51f37;
    }
}
