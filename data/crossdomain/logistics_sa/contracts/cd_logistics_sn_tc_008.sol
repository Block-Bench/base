// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Decentralized lending and borrowing platform
 * @dev Users can deposit collateral and borrow against it
 */

interface IOracle {
    function getUnderlyingPrice(address cInventorytoken) external view returns (uint256);
}

interface IcShipmenttoken {
    function registerShipment(uint256 loginventoryAmount) external;

    function requestCapacity(uint256 borrowstorageAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract CapacityleaseProtocol {
    // Oracle for getting asset prices
    IOracle public oracle;

    // Collateral factors
    mapping(address => uint256) public cargoguaranteeFactors;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public shipperDeposits;

    // User borrows
    mapping(address => mapping(address => uint256)) public buyerBorrows;

    // Supported markets
    mapping(address => bool) public supportedMarkets;

    event StoreGoods(address indexed vendor, address indexed cInventorytoken, uint256 amount);
    event BorrowStorage(address indexed vendor, address indexed cInventorytoken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    /**
     * @notice Mint cTokens by depositing underlying assets
     * @param cToken The cToken to mint
     * @param amount Amount of underlying to deposit
     */
    function registerShipment(address cInventorytoken, uint256 amount) external {
        require(supportedMarkets[cInventorytoken], "Market not supported");

        // Mint cTokens to user
        shipperDeposits[msg.sender][cInventorytoken] += amount;

        emit StoreGoods(msg.sender, cInventorytoken, amount);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The cToken to borrow
     * @param amount Amount to borrow
     */
    function requestCapacity(address cInventorytoken, uint256 amount) external {
        require(supportedMarkets[cInventorytoken], "Market not supported");

        // Calculate user's borrowing power
        uint256 requestcapacityPower = calculateRequestcapacityPower(msg.sender);

        // Calculate current total borrows value
        uint256 currentBorrows = calculateTotalBorrows(msg.sender);

        // Get value of new borrow
        uint256 leasecapacityValue = (oracle.getUnderlyingPrice(cInventorytoken) * amount) /
            1e18;

        // Check if user has enough collateral
        require(
            currentBorrows + leasecapacityValue <= requestcapacityPower,
            "Insufficient collateral"
        );

        // Update borrow balance
        buyerBorrows[msg.sender][cInventorytoken] += amount;

        emit BorrowStorage(msg.sender, cInventorytoken, amount);
    }

    /**
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD
     */
    function calculateRequestcapacityPower(address vendor) public view returns (uint256) {
        uint256 totalPower = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cInventorytoken = markets[i];
            uint256 warehouseLevel = shipperDeposits[vendor][cInventorytoken];

            if (warehouseLevel > 0) {
                // Get price from oracle
                uint256 price = oracle.getUnderlyingPrice(cInventorytoken);

                // Calculate value
                uint256 value = (warehouseLevel * price) / 1e18;

                // Apply collateral factor
                uint256 power = (value * cargoguaranteeFactors[cInventorytoken]) / 1e18;

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
    function calculateTotalBorrows(address vendor) public view returns (uint256) {
        uint256 totalBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cInventorytoken = markets[i];
            uint256 borrowed = buyerBorrows[vendor][cInventorytoken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cInventorytoken);
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
    function addMarket(address cInventorytoken, uint256 shipmentbondFactor) external {
        supportedMarkets[cInventorytoken] = true;
        cargoguaranteeFactors[cInventorytoken] = shipmentbondFactor;
    }
}
