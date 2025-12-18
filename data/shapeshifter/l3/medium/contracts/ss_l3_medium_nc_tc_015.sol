pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address _0x0e67f5, uint256 _0x04fd16) external returns (bool);

    function _0x3ae69b(address _0x83953b) external view returns (uint256);
}

contract CompoundMarket {
    address public _0xea00a1;
    address public _0x64f2de;

    mapping(address => uint256) public _0x10612b;
    uint256 public _0x0d5c7f;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        _0x64f2de = msg.sender;
        _0xea00a1 = OLD_TUSD;
    }

    function _0x216339(uint256 _0x04fd16) external {
        IERC20(NEW_TUSD).transfer(address(this), _0x04fd16);
        _0x10612b[msg.sender] += _0x04fd16;
        _0x0d5c7f += _0x04fd16;
    }

    function _0x71c80d(address _0xbe6a89) external {
        require(_0xbe6a89 != _0xea00a1, "Cannot sweep underlying token");

        uint256 balance = IERC20(_0xbe6a89)._0x3ae69b(address(this));
        IERC20(_0xbe6a89).transfer(msg.sender, balance);
    }

    function _0x416c1d(uint256 _0x04fd16) external {
        require(_0x10612b[msg.sender] >= _0x04fd16, "Insufficient balance");

        _0x10612b[msg.sender] -= _0x04fd16;
        _0x0d5c7f -= _0x04fd16;

        IERC20(NEW_TUSD).transfer(msg.sender, _0x04fd16);
    }
}