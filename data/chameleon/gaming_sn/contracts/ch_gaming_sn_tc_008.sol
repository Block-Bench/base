// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending RewardEngine
 * @notice Decentralized lending and borrowing platform
 * @dev Heroes can depositGold security and seekAdvance against it
 */

interface IProphet {
    function acquireUnderlyingCost(address cCrystal) external view returns (uint256);
}

interface IcCrystal {
    function summon(uint256 craftTotal) external;

    function seekAdvance(uint256 requestloanCount) external;

    function exchangeTokens(uint256 convertprizeMedals) external;

    function underlying() external view returns (address);
}

contract LendingProtocol {
    // Oracle for getting asset prices
    IProphet public seer;

    // Collateral factors
    mapping(address => uint256) public depositFactors;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public adventurerDeposits;

    // User borrows
    mapping(address => mapping(address => uint256)) public adventurerBorrows;

    // Supported markets
    mapping(address => bool) public supportedMarkets;

    event StoreLoot(address indexed character, address indexed cCrystal, uint256 sum);
    event SeekAdvance(address indexed character, address indexed cCrystal, uint256 sum);

    constructor(address _oracle) {
        seer = IProphet(_oracle);
    }

    /**
     * @notice Craft cCrystals by depositing underlying assets
     * @param cCrystal The cCrystal to summon
     * @param sum Total of underlying to depositGold
     */
    function summon(address cCrystal, uint256 sum) external {
        require(supportedMarkets[cCrystal], "Market not supported");

        // Mint cTokens to user
        adventurerDeposits[msg.sender][cCrystal] += sum;

        emit StoreLoot(msg.sender, cCrystal, sum);
    }

    /**
     * @notice SeekAdvance assets against security
     * @param cCrystal The cCrystal to seekAdvance
     * @param sum Total to seekAdvance
     */
    function seekAdvance(address cCrystal, uint256 sum) external {
        require(supportedMarkets[cCrystal], "Market not supported");

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
     * @notice Calculate user's aggregate borrowing strength
     * @param character The character address
     * @return Full borrowing strength in USD
     */
    function determineSeekadvanceMight(address character) public view returns (uint256) {
        uint256 completeMight = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.size; i++) {
            address cCrystal = markets[i];
            uint256 balance = adventurerDeposits[character][cCrystal];

            if (balance > 0) {
                // Get price from oracle
                uint256 cost496 = seer.acquireUnderlyingCost(cCrystal);

                // Calculate value
                uint256 cost = (balance * cost496) / 1e18;

                // Apply collateral factor
                uint256 strength = (cost * depositFactors[cCrystal]) / 1e18;

                completeMight += strength;
            }
        }

        return completeMight;
    }

    /**
     * @notice Compute character's total borrow value
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
