// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Decentralized lending and borrowing platform
 * @dev Users can deposit collateral and borrow against it
 */

interface IOracle {
    function getUnderlyingPrice(address cGoldtoken) external view returns (uint256);
}

interface IcQuesttoken {
    function createItem(uint256 craftgearAmount) external;

    function requestLoan(uint256 borrowgoldAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract GoldlendingProtocol {
    // Oracle for getting asset prices
    IOracle public oracle;

    // Collateral factors
    mapping(address => uint256) public depositFactors;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public heroDeposits;

    // User borrows
    mapping(address => mapping(address => uint256)) public playerBorrows;

    // Supported markets
    mapping(address => bool) public supportedMarkets;

    event StoreLoot(address indexed adventurer, address indexed cGoldtoken, uint256 amount);
    event BorrowGold(address indexed adventurer, address indexed cGoldtoken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    /**
     * @notice Mint cTokens by depositing underlying assets
     * @param cToken The cToken to mint
     * @param amount Amount of underlying to deposit
     */
    function createItem(address cGoldtoken, uint256 amount) external {
        require(supportedMarkets[cGoldtoken], "Market not supported");

        // Mint cTokens to user
        heroDeposits[msg.sender][cGoldtoken] += amount;

        emit StoreLoot(msg.sender, cGoldtoken, amount);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The cToken to borrow
     * @param amount Amount to borrow
     */
    function requestLoan(address cGoldtoken, uint256 amount) external {
        require(supportedMarkets[cGoldtoken], "Market not supported");

        // Calculate user's borrowing power
        uint256 requestloanPower = calculateRequestloanPower(msg.sender);

        // Calculate current total borrows value
        uint256 currentBorrows = calculateTotalBorrows(msg.sender);

        // Get value of new borrow
        uint256 getloanValue = (oracle.getUnderlyingPrice(cGoldtoken) * amount) /
            1e18;

        // Check if user has enough collateral
        require(
            currentBorrows + getloanValue <= requestloanPower,
            "Insufficient collateral"
        );

        // Update borrow balance
        playerBorrows[msg.sender][cGoldtoken] += amount;

        emit BorrowGold(msg.sender, cGoldtoken, amount);
    }

    /**
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD
     */
    function calculateRequestloanPower(address adventurer) public view returns (uint256) {
        uint256 totalPower = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cGoldtoken = markets[i];
            uint256 itemCount = heroDeposits[adventurer][cGoldtoken];

            if (itemCount > 0) {
                // Get price from oracle
                uint256 price = oracle.getUnderlyingPrice(cGoldtoken);

                // Calculate value
                uint256 value = (itemCount * price) / 1e18;

                // Apply collateral factor
                uint256 power = (value * depositFactors[cGoldtoken]) / 1e18;

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
    function calculateTotalBorrows(address adventurer) public view returns (uint256) {
        uint256 totalBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cGoldtoken = markets[i];
            uint256 borrowed = playerBorrows[adventurer][cGoldtoken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cGoldtoken);
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
    function addMarket(address cGoldtoken, uint256 pledgeFactor) external {
        supportedMarkets[cGoldtoken] = true;
        depositFactors[cGoldtoken] = pledgeFactor;
    }
}
