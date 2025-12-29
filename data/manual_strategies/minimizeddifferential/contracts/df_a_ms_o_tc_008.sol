// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Decentralized lending and borrowing platform
 * @dev Users can deposit collateral and borrow against it
 */

interface IOracle {
    function getUnderlyingPrice(address cToken) external view returns (uint256);
}

interface ICToken {
    function mint(uint256 mintAmount) external;

    function borrow(uint256 borrowAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract CreamLending {
    // Oracle for getting asset prices
    IOracle public oracle;

    // Collateral factors
    mapping(address => uint256) public collateralFactors;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public userDeposits;

    // User borrows
    mapping(address => mapping(address => uint256)) public userBorrows;

    // Supported markets
    mapping(address => bool) public supportedMarkets;

    // Price deviation protection
    mapping(address => uint256) public lastKnownPrice;
    mapping(address => uint256) public lastPriceUpdate;
    uint256 public constant MAX_PRICE_DEVIATION = 10; // 10%
    uint256 public constant MIN_PRICE_UPDATE_INTERVAL = 1 hours;

    event Deposit(address indexed user, address indexed cToken, uint256 amount);
    event Borrow(address indexed user, address indexed cToken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    function _validatePrice(address cToken) internal view returns (uint256) {
        uint256 currentPrice = oracle.getUnderlyingPrice(cToken);
        uint256 lastPrice = lastKnownPrice[cToken];

        if (lastPrice > 0 && block.timestamp < lastPriceUpdate[cToken] + MIN_PRICE_UPDATE_INTERVAL) {
            uint256 maxAllowed = lastPrice * (100 + MAX_PRICE_DEVIATION) / 100;
            uint256 minAllowed = lastPrice * (100 - MAX_PRICE_DEVIATION) / 100;
            require(currentPrice >= minAllowed && currentPrice <= maxAllowed, "Price deviation too high");
        }

        return currentPrice;
    }

    /**
     * @notice Mint cTokens by depositing underlying assets
     * @param cToken The cToken to mint
     * @param amount Amount of underlying to deposit
     */
    function mint(address cToken, uint256 amount) external {
        require(supportedMarkets[cToken], "Market not supported");

        // Mint cTokens to user
        userDeposits[msg.sender][cToken] += amount;

        emit Deposit(msg.sender, cToken, amount);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The cToken to borrow
     * @param amount Amount to borrow
     */
    function borrow(address cToken, uint256 amount) external {
        require(supportedMarkets[cToken], "Market not supported");

        // Calculate user's borrowing power
        uint256 borrowPower = calculateBorrowPower(msg.sender);

        // Calculate current total borrows value
        uint256 currentBorrows = calculateTotalBorrows(msg.sender);

        // Get validated price (with deviation check)
        uint256 price = _validatePrice(cToken);
        uint256 borrowValue = (price * amount) / 1e18;

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
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD
     */
    function calculateBorrowPower(address user) public view returns (uint256) {
        uint256 totalPower = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cToken = markets[i];
            uint256 balance = userDeposits[user][cToken];

            if (balance > 0) {
                // Get price from oracle
                uint256 price = oracle.getUnderlyingPrice(cToken);

                // Calculate value
                uint256 value = (balance * price) / 1e18;

                // Apply collateral factor
                uint256 power = (value * collateralFactors[cToken]) / 1e18;

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

    /**
     * @notice Update cached price (admin function)
     */
    function updateCachedPrice(address cToken) external {
        lastKnownPrice[cToken] = oracle.getUnderlyingPrice(cToken);
        lastPriceUpdate[cToken] = block.timestamp;
    }
}
