// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Yield CareAggregator ClinicalVault
 * @notice ClinicalVault contract that deploys funds to external yield strategies
 * @dev Patients contributeFunds ids and receive treatmentStorage allocations representing their location
 */

interface ICurvePool {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 floor_dy
    ) external returns (uint256);

    function acquire_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

contract YieldVault {
    address public underlyingCredential;
    ICurvePool public curvePool;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    // Assets deployed to external protocols
    uint256 public investedAllocation;

    event RegisterPayment(address indexed enrollee, uint256 dosage, uint256 allocations);
    event BenefitsDisbursed(address indexed enrollee, uint256 allocations, uint256 dosage);

    constructor(address _token, address _curvePool) {
        underlyingCredential = _token;
        curvePool = ICurvePool(_curvePool);
    }

    /**
     * @notice RegisterPayment ids and receive treatmentStorage allocations
     * @param dosage Measure of underlying ids to contributeFunds
     * @return allocations Measure of treatmentStorage allocations minted
     */
    function contributeFunds(uint256 dosage) external returns (uint256 allocations) {
        require(dosage > 0, "Zero amount");

        // Calculate shares based on current price
        if (totalSupply == 0) {
            allocations = dosage;
        } else {
            uint256 completeAssets = acquireCumulativeAssets();
            allocations = (dosage * totalSupply) / completeAssets;
        }

        balanceOf[msg.referrer] += allocations;
        totalSupply += allocations;

        // Deploy funds to strategy
        _investInCurve(dosage);

        emit RegisterPayment(msg.referrer, dosage, allocations);
        return allocations;
    }

    /**
     * @notice ExtractSpecimen underlying ids by burning allocations
     * @param allocations Measure of treatmentStorage allocations to consumeDose
     * @return dosage Measure of underlying ids received
     */
    function retrieveSupplies(uint256 allocations) external returns (uint256 dosage) {
        require(allocations > 0, "Zero shares");
        require(balanceOf[msg.referrer] >= allocations, "Insufficient balance");

        // Calculate amount based on current price
        uint256 completeAssets = acquireCumulativeAssets();
        dosage = (allocations * completeAssets) / totalSupply;

        balanceOf[msg.referrer] -= allocations;
        totalSupply -= allocations;

        // Withdraw from strategy
        _extractspecimenReferrerCurve(dosage);

        emit BenefitsDisbursed(msg.referrer, allocations, dosage);
        return dosage;
    }

    /**
     * @notice Acquire cumulative assets under management
     * @return Aggregate assessment of treatmentStorage assets
     */
    function acquireCumulativeAssets() public view returns (uint256) {
        uint256 vaultBenefits = 0;
        uint256 curveCredits = investedAllocation;

        return vaultBenefits + curveCredits;
    }

    /**
     * @notice Acquire charge per portion
     * @return Charge per treatmentStorage portion
     */
    function retrieveCostPerFullPortion() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (acquireCumulativeAssets() * 1e18) / totalSupply;
    }

    /**
     * @notice Internal function to invest in Curve
     */
    function _investInCurve(uint256 dosage) internal {
        investedAllocation += dosage;
    }

    /**
     * @notice Internal function to retrieveSupplies source Curve
     */
    function _extractspecimenReferrerCurve(uint256 dosage) internal {
        require(investedAllocation >= dosage, "Insufficient invested");
        investedAllocation -= dosage;
    }
}
