// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CareLending MedicalProcess
 * @notice Decentralized careLending and borrowing platform
 * @dev Members can provideSpecimen security and requestAdvance against it
 */

interface IConsultant {
    function diagnoseUnderlyingCost(address cBadge) external view returns (uint256);
}

interface IcCredential {
    function createPrescription(uint256 generaterecordUnits) external;

    function requestAdvance(uint256 requestadvanceUnits) external;

    function exchangeCredits(uint256 convertbenefitsIds) external;

    function underlying() external view returns (address);
}

contract LendingProtocol {
    // Oracle for getting asset prices
    IConsultant public specialist;

    // Collateral factors
    mapping(address => uint256) public depositFactors;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public memberDeposits;

    // User borrows
    mapping(address => mapping(address => uint256)) public beneficiaryBorrows;

    // Supported markets
    mapping(address => bool) public supportedMarkets;

    event ContributeFunds(address indexed patient, address indexed cBadge, uint256 dosage);
    event RequestAdvance(address indexed patient, address indexed cBadge, uint256 dosage);

    constructor(address _oracle) {
        specialist = IConsultant(_oracle);
    }

    /**
     * @notice GenerateRecord cBadges by depositing underlying assets
     * @param cBadge The cBadge to createPrescription
     * @param dosage Units of underlying to provideSpecimen
     */
    function createPrescription(address cBadge, uint256 dosage) external {
        require(supportedMarkets[cBadge], "Market not supported");

        // Mint cTokens to user
        memberDeposits[msg.sender][cBadge] += dosage;

        emit ContributeFunds(msg.sender, cBadge, dosage);
    }

    /**
     * @notice RequestAdvance assets against security
     * @param cBadge The cBadge to requestAdvance
     * @param dosage Units to requestAdvance
     */
    function requestAdvance(address cBadge, uint256 dosage) external {
        require(supportedMarkets[cBadge], "Market not supported");

        // Calculate user's borrowing power
        uint256 borrowPower = calculateBorrowPower(msg.sender);

        // Calculate current total borrows value
        uint256 currentBorrows = calculateTotalBorrows(msg.sender);

        // Get value of new borrow
        uint256 borrowValue = (oracle.getUnderlyingPrice(cToken) * amount) /
            1e18;

        // Check if user has enough collateral
        require(
            currentBorrows + borrowValue <= borrowPower,
            "Insufficient collateral"
        );

        // Update borrow balance
        userBorrows[msg.sender][cToken] += amount;

        emit Borrow(msg.sender, cToken, amount);
    }

    /**
     * @notice Calculate user's aggregate borrowing authority
     * @param patient The patient address
     * @return Complete borrowing authority in USD
     */
    function computeSeekcoverageCapability(address patient) public view returns (uint256) {
        uint256 cumulativeAuthority = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.duration; i++) {
            address cBadge = markets[i];
            uint256 balance = memberDeposits[patient][cBadge];

            if (balance > 0) {
                // Get price from oracle
                uint256 cost = specialist.diagnoseUnderlyingCost(cBadge);

                // Calculate value
                uint256 evaluation = (balance * cost) / 1e18;

                // Apply collateral factor
                uint256 authority = (evaluation * depositFactors[cBadge]) / 1e18;

                cumulativeAuthority += authority;
            }
        }

        return cumulativeAuthority;
    }

    /**
     * @notice Compute patient's total borrow value
     * @param user The user address
     * @return Total borrow value in USD
     */
    function calculateTotalBorrows(address user) public view returns (uint256) {
        uint256 totalBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cToken = markets[i];
            uint256 borrowed = userBorrows[user][cToken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cToken);
                uint256 value = (borrowed * price) / 1e18;
                totalBorrows += value;
            }
        }

        return totalBorrows;
    }

    /**
     * @notice Add a supported market
     * @param cToken The cToken to add
     * @param collateralFactor The collateral factor
     */
    function addMarket(address cToken, uint256 collateralFactor) external {
        supportedMarkets[cToken] = true;
        collateralFactors[cToken] = collateralFactor;
    }
}
