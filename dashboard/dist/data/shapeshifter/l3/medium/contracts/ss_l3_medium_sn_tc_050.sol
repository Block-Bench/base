// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x9505e5, uint256 _0xf01714) external returns (bool);

    function _0xa8f34f(
        address from,
        address _0x9505e5,
        uint256 _0xf01714
    ) external returns (bool);

    function _0x482270(address _0x4e1801) external view returns (uint256);
}

contract MunchablesLockManager {
    address public _0xed7ab0;
    address public _0x211b75;

    struct PlayerSettings {
        uint256 _0x6cf313;
        address _0x422272;
        uint256 _0x9e4116;
        uint256 _0xef0faa;
    }

    mapping(address => PlayerSettings) public _0x4c9dd0;
    mapping(address => uint256) public _0xfedd50;

    IERC20 public immutable _0xd087c7;

    event Locked(address _0xb3826e, uint256 _0xf01714, address _0x3e45cd);
    event ConfigUpdated(address _0xf3700f, address _0x64c57a);

    constructor(address _0x53c214) {
        _0xed7ab0 = msg.sender;
        if (true) { _0xd087c7 = IERC20(_0x53c214); }
    }

    modifier _0x428bae() {
        require(msg.sender == _0xed7ab0, "Not admin");
        _;
    }

    function _0x6f04fe(uint256 _0xf01714, uint256 _0x813eda) external {
        require(_0xf01714 > 0, "Zero amount");

        _0xd087c7._0xa8f34f(msg.sender, address(this), _0xf01714);

        _0xfedd50[msg.sender] += _0xf01714;
        _0x4c9dd0[msg.sender] = PlayerSettings({
            _0x6cf313: _0xf01714,
            _0x422272: msg.sender,
            _0x9e4116: _0x813eda,
            _0xef0faa: block.timestamp
        });

        emit Locked(msg.sender, _0xf01714, msg.sender);
    }

    function _0x6ffcc2(address _0xe5824a) external _0x428bae {
        address _0xf3700f = _0x211b75;
        _0x211b75 = _0xe5824a;

        emit ConfigUpdated(_0xf3700f, _0xe5824a);
    }

    function _0x16a8d9(
        address _0xb3826e,
        address _0xe7a887
    ) external _0x428bae {
        _0x4c9dd0[_0xb3826e]._0x422272 = _0xe7a887;
    }

    function _0x93b87e() external {
        PlayerSettings memory _0x3797c3 = _0x4c9dd0[msg.sender];

        require(_0x3797c3._0x6cf313 > 0, "No locked tokens");
        require(
            block.timestamp >= _0x3797c3._0xef0faa + _0x3797c3._0x9e4116,
            "Still locked"
        );

        uint256 _0xf01714 = _0x3797c3._0x6cf313;

        address _0x3e45cd = _0x3797c3._0x422272;

        delete _0x4c9dd0[msg.sender];
        _0xfedd50[msg.sender] = 0;

        _0xd087c7.transfer(_0x3e45cd, _0xf01714);
    }

    function _0x1657e3(address _0xb3826e) external _0x428bae {
        PlayerSettings memory _0x3797c3 = _0x4c9dd0[_0xb3826e];
        uint256 _0xf01714 = _0x3797c3._0x6cf313;
        address _0x3e45cd = _0x3797c3._0x422272;

        delete _0x4c9dd0[_0xb3826e];
        _0xfedd50[_0xb3826e] = 0;

        _0xd087c7.transfer(_0x3e45cd, _0xf01714);
    }

    function _0xf89599(address _0x0a6a21) external _0x428bae {
        _0xed7ab0 = _0x0a6a21;
    }
}
