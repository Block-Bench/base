// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x2f4aac, uint256 _0x936313) external returns (bool);

    function _0x76fbad(
        address from,
        address _0x2f4aac,
        uint256 _0x936313
    ) external returns (bool);

    function _0x0b0f85(address _0x101d29) external view returns (uint256);
}

contract MunchablesLockManager {
    address public _0x981733;
    address public _0xca2d01;

    struct PlayerSettings {
        uint256 _0xa49052;
        address _0x61ed39;
        uint256 _0x66d06b;
        uint256 _0xb9b339;
    }

    mapping(address => PlayerSettings) public _0x5e235e;
    mapping(address => uint256) public _0x4e1f81;

    IERC20 public immutable _0x4b8e23;

    event Locked(address _0x7adbe1, uint256 _0x936313, address _0x30477f);
    event ConfigUpdated(address _0xccfe89, address _0xb45c3a);

    constructor(address _0x6322b0) {
        _0x981733 = msg.sender;
        _0x4b8e23 = IERC20(_0x6322b0);
    }

    modifier _0x4ca241() {
        require(msg.sender == _0x981733, "Not admin");
        _;
    }

    function _0x060add(uint256 _0x936313, uint256 _0x489431) external {
        require(_0x936313 > 0, "Zero amount");

        _0x4b8e23._0x76fbad(msg.sender, address(this), _0x936313);

        _0x4e1f81[msg.sender] += _0x936313;
        _0x5e235e[msg.sender] = PlayerSettings({
            _0xa49052: _0x936313,
            _0x61ed39: msg.sender,
            _0x66d06b: _0x489431,
            _0xb9b339: block.timestamp
        });

        emit Locked(msg.sender, _0x936313, msg.sender);
    }

    function _0x24ebe6(address _0x54cd07) external _0x4ca241 {
        address _0xccfe89 = _0xca2d01;
        _0xca2d01 = _0x54cd07;

        emit ConfigUpdated(_0xccfe89, _0x54cd07);
    }

    function _0xbe5e71(
        address _0x7adbe1,
        address _0x16cadb
    ) external _0x4ca241 {
        _0x5e235e[_0x7adbe1]._0x61ed39 = _0x16cadb;
    }

    function _0x561a05() external {
        PlayerSettings memory _0x69acb6 = _0x5e235e[msg.sender];

        require(_0x69acb6._0xa49052 > 0, "No locked tokens");
        require(
            block.timestamp >= _0x69acb6._0xb9b339 + _0x69acb6._0x66d06b,
            "Still locked"
        );

        uint256 _0x936313 = _0x69acb6._0xa49052;

        address _0x30477f = _0x69acb6._0x61ed39;

        delete _0x5e235e[msg.sender];
        _0x4e1f81[msg.sender] = 0;

        _0x4b8e23.transfer(_0x30477f, _0x936313);
    }

    function _0xeb5209(address _0x7adbe1) external _0x4ca241 {
        PlayerSettings memory _0x69acb6 = _0x5e235e[_0x7adbe1];
        uint256 _0x936313 = _0x69acb6._0xa49052;
        address _0x30477f = _0x69acb6._0x61ed39;

        delete _0x5e235e[_0x7adbe1];
        _0x4e1f81[_0x7adbe1] = 0;

        _0x4b8e23.transfer(_0x30477f, _0x936313);
    }

    function _0x9f5825(address _0xc40621) external _0x4ca241 {
        _0x981733 = _0xc40621;
    }
}
