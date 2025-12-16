// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Decentralized lending and borrowing platform
 * @dev Users can deposit collateral and borrow against it
 */

interface IOracle {
    function getUnderlyingPrice(address cCoveragetoken) external view returns (uint256);
}

interface IcBenefittoken {
    function issueCoverage(uint256 generatecreditAmount) external;

    function requestAdvance(uint256 borrowcreditAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract HealthcreditProtocol {
    // Oracle for getting asset prices
    IOracle public oracle;

    // Collateral factors
    mapping(address => uint256) public healthbondFactors;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public beneficiaryDeposits;

    // User borrows
    mapping(address => mapping(address => uint256)) public patientBorrows;

    // Supported markets
    mapping(address => bool) public supportedMarkets;

    event ContributePremium(address indexed enrollee, address indexed cCoveragetoken, uint256 amount);
    event BorrowCredit(address indexed enrollee, address indexed cCoveragetoken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    /**
     * @notice Mint cTokens by depositing underlying assets
     * @param cToken The cToken to mint
     * @param amount Amount of underlying to deposit
     */
    function issueCoverage(address cCoveragetoken, uint256 amount) external {
        require(supportedMarkets[cCoveragetoken], "Market not supported");

        // Mint cTokens to user
        beneficiaryDeposits[msg.sender][cCoveragetoken] += amount;

        emit ContributePremium(msg.sender, cCoveragetoken, amount);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The cToken to borrow
     * @param amount Amount to borrow
     */
    function requestAdvance(address cCoveragetoken, uint256 amount) external {
        require(supportedMarkets[cCoveragetoken], "Market not supported");

        // Calculate user's borrowing power
        uint256 requestadvancePower = calculateRequestadvancePower(msg.sender);

        // Calculate current total borrows value
        uint256 currentBorrows = calculateTotalBorrows(msg.sender);

        // Get value of new borrow
        uint256 accesscreditValue = (oracle.getUnderlyingPrice(cCoveragetoken) * amount) /
            1e18;

        // Check if user has enough collateral
        require(
            currentBorrows + accesscreditValue <= requestadvancePower,
            "Insufficient collateral"
        );

        // Update borrow balance
        patientBorrows[msg.sender][cCoveragetoken] += amount;

        emit BorrowCredit(msg.sender, cCoveragetoken, amount);
    }

    /**
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD
     */
    function calculateRequestadvancePower(address enrollee) public view returns (uint256) {
        uint256 totalPower = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cCoveragetoken = markets[i];
            uint256 remainingBenefit = beneficiaryDeposits[enrollee][cCoveragetoken];

            if (remainingBenefit > 0) {
                // Get price from oracle
                uint256 price = oracle.getUnderlyingPrice(cCoveragetoken);

                // Calculate value
                uint256 value = (remainingBenefit * price) / 1e18;

                // Apply collateral factor
                uint256 power = (value * healthbondFactors[cCoveragetoken]) / 1e18;

                totalPower += power;
            }
        }

        return totalPower;
    }

    /**
     * @notice Calculate user's total borrow value
     * @param user The user address
     * @return Total borrow value in USD
     */
    function calculateTotalBorrows(address enrollee) public view returns (uint256) {
        uint256 totalBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cCoveragetoken = markets[i];
            uint256 borrowed = patientBorrows[enrollee][cCoveragetoken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cCoveragetoken);
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
    function addMarket(address cCoveragetoken, uint256 securitybondFactor) external {
        supportedMarkets[cCoveragetoken] = true;
        healthbondFactors[cCoveragetoken] = securitybondFactor;
    }
}
