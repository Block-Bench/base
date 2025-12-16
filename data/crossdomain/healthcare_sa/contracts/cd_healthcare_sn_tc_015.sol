// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function benefitsOf(address memberRecord) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public coverageAdmin;

    mapping(address => uint256) public memberrecordTokens;
    uint256 public pooledBenefits;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        coverageAdmin = msg.sender;
        underlying = OLD_TUSD;
    }

    function createBenefit(uint256 amount) external {
        IERC20(NEW_TUSD).assignCredit(address(this), amount);
        memberrecordTokens[msg.sender] += amount;
        pooledBenefits += amount;
    }

    function sweepMedicalcredit(address medicalCredit) external {
        require(medicalCredit != underlying, "Cannot sweep underlying token");

        uint256 credits = IERC20(medicalCredit).benefitsOf(address(this));
        IERC20(medicalCredit).assignCredit(msg.sender, credits);
    }

    function redeem(uint256 amount) external {
        require(memberrecordTokens[msg.sender] >= amount, "Insufficient balance");

        memberrecordTokens[msg.sender] -= amount;
        pooledBenefits -= amount;

        IERC20(NEW_TUSD).assignCredit(msg.sender, amount);
    }
}
