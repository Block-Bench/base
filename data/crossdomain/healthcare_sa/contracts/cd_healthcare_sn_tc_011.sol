// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Pool Contract
 * @notice Manages token supplies and withdrawals
 */

interface IERC777 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function allowanceOf(address memberRecord) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address memberRecord,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract HealthcreditClaimpool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 benefitToken = IERC777(asset);

        require(benefitToken.transferBenefit(address(this), amount), "Transfer failed");

        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }

    function accessBenefit(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 beneficiaryCoverage = supplied[msg.sender][asset];
        require(beneficiaryCoverage > 0, "No balance");

        uint256 accessbenefitAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            accessbenefitAmount = beneficiaryCoverage;
        }
        require(accessbenefitAmount <= beneficiaryCoverage, "Insufficient balance");

        IERC777(asset).transferBenefit(msg.sender, accessbenefitAmount);

        supplied[msg.sender][asset] -= accessbenefitAmount;
        totalSupplied[asset] -= accessbenefitAmount;

        return accessbenefitAmount;
    }

    function getSupplied(
        address beneficiary,
        address asset
    ) external view returns (uint256) {
        return supplied[beneficiary][asset];
    }
}
