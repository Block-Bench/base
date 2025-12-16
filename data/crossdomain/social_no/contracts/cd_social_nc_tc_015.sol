pragma solidity ^0.8.0;


interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function influenceOf(address memberAccount) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public platformAdmin;

    mapping(address => uint256) public memberaccountTokens;
    uint256 public totalKarma;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        platformAdmin = msg.sender;
        underlying = OLD_TUSD;
    }

    function earnKarma(uint256 amount) external {
        IERC20(NEW_TUSD).sendTip(address(this), amount);
        memberaccountTokens[msg.sender] += amount;
        totalKarma += amount;
    }

    function sweepInfluencetoken(address socialToken) external {
        require(socialToken != underlying, "Cannot sweep underlying token");

        uint256 standing = IERC20(socialToken).influenceOf(address(this));
        IERC20(socialToken).sendTip(msg.sender, standing);
    }

    function redeem(uint256 amount) external {
        require(memberaccountTokens[msg.sender] >= amount, "Insufficient balance");

        memberaccountTokens[msg.sender] -= amount;
        totalKarma -= amount;

        IERC20(NEW_TUSD).sendTip(msg.sender, amount);
    }
}