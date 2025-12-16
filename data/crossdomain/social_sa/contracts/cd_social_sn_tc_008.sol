// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Decentralized lending and borrowing platform
 * @dev Users can deposit collateral and borrow against it
 */

interface IOracle {
    function getUnderlyingPrice(address cReputationtoken) external view returns (uint256);
}

interface IcSocialtoken {
    function earnKarma(uint256 buildinfluenceAmount) external;

    function requestSupport(uint256 askforbackingAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract SocialcreditProtocol {
    // Oracle for getting asset prices
    IOracle public oracle;

    // Collateral factors
    mapping(address => uint256) public pledgeFactors;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public contributorDeposits;

    // User borrows
    mapping(address => mapping(address => uint256)) public supporterBorrows;

    // Supported markets
    mapping(address => bool) public supportedMarkets;

    event Contribute(address indexed follower, address indexed cReputationtoken, uint256 amount);
    event RequestSupport(address indexed follower, address indexed cReputationtoken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    /**
     * @notice Mint cTokens by depositing underlying assets
     * @param cToken The cToken to mint
     * @param amount Amount of underlying to deposit
     */
    function earnKarma(address cReputationtoken, uint256 amount) external {
        require(supportedMarkets[cReputationtoken], "Market not supported");

        // Mint cTokens to user
        contributorDeposits[msg.sender][cReputationtoken] += amount;

        emit Contribute(msg.sender, cReputationtoken, amount);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The cToken to borrow
     * @param amount Amount to borrow
     */
    function requestSupport(address cReputationtoken, uint256 amount) external {
        require(supportedMarkets[cReputationtoken], "Market not supported");

        // Calculate user's borrowing power
        uint256 seekfundingPower = calculateRequestsupportPower(msg.sender);

        // Calculate current total borrows value
        uint256 currentBorrows = calculateTotalBorrows(msg.sender);

        // Get value of new borrow
        uint256 requestsupportValue = (oracle.getUnderlyingPrice(cReputationtoken) * amount) /
            1e18;

        // Check if user has enough collateral
        require(
            currentBorrows + requestsupportValue <= seekfundingPower,
            "Insufficient collateral"
        );

        // Update borrow balance
        supporterBorrows[msg.sender][cReputationtoken] += amount;

        emit RequestSupport(msg.sender, cReputationtoken, amount);
    }

    /**
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD
     */
    function calculateRequestsupportPower(address follower) public view returns (uint256) {
        uint256 totalPower = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cReputationtoken = markets[i];
            uint256 credibility = contributorDeposits[follower][cReputationtoken];

            if (credibility > 0) {
                // Get price from oracle
                uint256 price = oracle.getUnderlyingPrice(cReputationtoken);

                // Calculate value
                uint256 value = (credibility * price) / 1e18;

                // Apply collateral factor
                uint256 power = (value * pledgeFactors[cReputationtoken]) / 1e18;

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
    function calculateTotalBorrows(address follower) public view returns (uint256) {
        uint256 totalBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cReputationtoken = markets[i];
            uint256 borrowed = supporterBorrows[follower][cReputationtoken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cReputationtoken);
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
    function addMarket(address cReputationtoken, uint256 guaranteeFactor) external {
        supportedMarkets[cReputationtoken] = true;
        pledgeFactors[cReputationtoken] = guaranteeFactor;
    }
}
