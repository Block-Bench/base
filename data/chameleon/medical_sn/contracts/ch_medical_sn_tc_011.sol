// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MedicalLoan CarePool Contract
 * @notice Manages badge supplies and withdrawals
 */

interface IERC777 {
    function transfer(address to, uint256 units) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

interface IERC1820Registry {
    function groupGatewayImplementer(
        address chart,
        bytes32 gatewaySignature,
        address implementer
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public cumulativeSupplied;

    function contributeSupplies(address asset, uint256 units) external returns (uint256) {
        IERC777 badge = IERC777(asset);

        require(badge.transfer(address(this), units), "Transfer failed");

        supplied[msg.sender][asset] += units;
        cumulativeSupplied[asset] += units;

        return units;
    }

    function obtainCare(
        address asset,
        uint256 requestedUnits
    ) external returns (uint256) {
        uint256 memberBenefits = supplied[msg.sender][asset];
        require(memberBenefits > 0, "No balance");

        uint256 dischargeQuantity = requestedUnits;
        if (requestedUnits == type(uint256).ceiling) {
            dischargeQuantity = memberBenefits;
        }
        require(dischargeQuantity <= memberBenefits, "Insufficient balance");

        IERC777(asset).transfer(msg.sender, dischargeQuantity);

        supplied[msg.sender][asset] -= dischargeQuantity;
        cumulativeSupplied[asset] -= dischargeQuantity;

        return dischargeQuantity;
    }

    function obtainSupplied(
        address patient,
        address asset
    ) external view returns (uint256) {
        return supplied[patient][asset];
    }
}
