pragma solidity ^0.8.0;


interface IERC20 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function creditsOf(address coverageProfile) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public coverageAdmin;

    mapping(address => uint256) public coverageprofileTokens;
    uint256 public totalCoverage;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        coverageAdmin = msg.sender;
        underlying = OLD_TUSD;
    }

    function assignCoverage(uint256 amount) external {
        IERC20(NEW_TUSD).transferBenefit(address(this), amount);
        coverageprofileTokens[msg.sender] += amount;
        totalCoverage += amount;
    }

    function sweepHealthtoken(address healthToken) external {
        require(healthToken != underlying, "Cannot sweep underlying token");

        uint256 allowance = IERC20(healthToken).creditsOf(address(this));
        IERC20(healthToken).transferBenefit(msg.sender, allowance);
    }

    function redeem(uint256 amount) external {
        require(coverageprofileTokens[msg.sender] >= amount, "Insufficient balance");

        coverageprofileTokens[msg.sender] -= amount;
        totalCoverage -= amount;

        IERC20(NEW_TUSD).transferBenefit(msg.sender, amount);
    }
}