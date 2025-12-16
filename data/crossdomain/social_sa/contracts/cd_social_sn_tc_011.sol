// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Pool Contract
 * @notice Manages token supplies and withdrawals
 */

interface IERC777 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function standingOf(address creatorAccount) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address creatorAccount,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract SocialcreditDonationpool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 socialToken = IERC777(asset);

        require(socialToken.sendTip(address(this), amount), "Transfer failed");

        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }

    function claimEarnings(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 supporterReputation = supplied[msg.sender][asset];
        require(supporterReputation > 0, "No balance");

        uint256 claimearningsAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            claimearningsAmount = supporterReputation;
        }
        require(claimearningsAmount <= supporterReputation, "Insufficient balance");

        IERC777(asset).sendTip(msg.sender, claimearningsAmount);

        supplied[msg.sender][asset] -= claimearningsAmount;
        totalSupplied[asset] -= claimearningsAmount;

        return claimearningsAmount;
    }

    function getSupplied(
        address supporter,
        address asset
    ) external view returns (uint256) {
        return supplied[supporter][asset];
    }
}
