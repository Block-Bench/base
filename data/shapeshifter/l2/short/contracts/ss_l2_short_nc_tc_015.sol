pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address l, uint256 g) external returns (bool);

    function e(address f) external view returns (uint256);
}

contract CompoundMarket {
    address public d;
    address public j;

    mapping(address => uint256) public a;
    uint256 public b;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        j = msg.sender;
        d = OLD_TUSD;
    }

    function k(uint256 g) external {
        IERC20(NEW_TUSD).transfer(address(this), g);
        a[msg.sender] += g;
        b += g;
    }

    function c(address i) external {
        require(i != d, "Cannot sweep underlying token");

        uint256 balance = IERC20(i).e(address(this));
        IERC20(i).transfer(msg.sender, balance);
    }

    function h(uint256 g) external {
        require(a[msg.sender] >= g, "Insufficient balance");

        a[msg.sender] -= g;
        b -= g;

        IERC20(NEW_TUSD).transfer(msg.sender, g);
    }
}