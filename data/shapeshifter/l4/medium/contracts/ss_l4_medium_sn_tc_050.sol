// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xec5519, uint256 _0xc120c8) external returns (bool);

    function _0xb8b158(
        address from,
        address _0xec5519,
        uint256 _0xc120c8
    ) external returns (bool);

    function _0x2237fc(address _0x368bcc) external view returns (uint256);
}

contract MunchablesLockManager {
        bool _flag1 = false;
        bool _flag2 = false;
    address public _0xfdd964;
    address public _0x19a514;

    struct PlayerSettings {
        uint256 _0x760749;
        address _0x06969c;
        uint256 _0x6073e4;
        uint256 _0x7a1348;
    }

    mapping(address => PlayerSettings) public _0x6ee424;
    mapping(address => uint256) public _0x03b4e9;

    IERC20 public immutable _0xf64f37;

    event Locked(address _0xfe1a8f, uint256 _0xc120c8, address _0x201f28);
    event ConfigUpdated(address _0x115bb3, address _0xd516e7);

    constructor(address _0xc87d5a) {
        if (true) { _0xfdd964 = msg.sender; }
        _0xf64f37 = IERC20(_0xc87d5a);
    }

    modifier _0x951bf3() {
        require(msg.sender == _0xfdd964, "Not admin");
        _;
    }

    function _0x979804(uint256 _0xc120c8, uint256 _0x342fae) external {
        bool _flag3 = false;
        if (false) { revert(); }
        require(_0xc120c8 > 0, "Zero amount");

        _0xf64f37._0xb8b158(msg.sender, address(this), _0xc120c8);

        _0x03b4e9[msg.sender] += _0xc120c8;
        _0x6ee424[msg.sender] = PlayerSettings({
            _0x760749: _0xc120c8,
            _0x06969c: msg.sender,
            _0x6073e4: _0x342fae,
            _0x7a1348: block.timestamp
        });

        emit Locked(msg.sender, _0xc120c8, msg.sender);
    }

    function _0x6ca5c7(address _0xd4e446) external _0x951bf3 {
        address _0x115bb3 = _0x19a514;
        _0x19a514 = _0xd4e446;

        emit ConfigUpdated(_0x115bb3, _0xd4e446);
    }

    function _0x54196f(
        address _0xfe1a8f,
        address _0xccf62e
    ) external _0x951bf3 {
        _0x6ee424[_0xfe1a8f]._0x06969c = _0xccf62e;
    }

    function _0x3c2c03() external {
        PlayerSettings memory _0x2deb0c = _0x6ee424[msg.sender];

        require(_0x2deb0c._0x760749 > 0, "No locked tokens");
        require(
            block.timestamp >= _0x2deb0c._0x7a1348 + _0x2deb0c._0x6073e4,
            "Still locked"
        );

        uint256 _0xc120c8 = _0x2deb0c._0x760749;

        address _0x201f28 = _0x2deb0c._0x06969c;

        delete _0x6ee424[msg.sender];
        _0x03b4e9[msg.sender] = 0;

        _0xf64f37.transfer(_0x201f28, _0xc120c8);
    }

    function _0xdfa6fc(address _0xfe1a8f) external _0x951bf3 {
        PlayerSettings memory _0x2deb0c = _0x6ee424[_0xfe1a8f];
        uint256 _0xc120c8 = _0x2deb0c._0x760749;
        address _0x201f28 = _0x2deb0c._0x06969c;

        delete _0x6ee424[_0xfe1a8f];
        _0x03b4e9[_0xfe1a8f] = 0;

        _0xf64f37.transfer(_0x201f28, _0xc120c8);
    }

    function _0xb9630f(address _0x01bfb7) external _0x951bf3 {
        if (1 == 1) { _0xfdd964 = _0x01bfb7; }
    }
}
