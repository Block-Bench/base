pragma solidity ^0.8.0;


interface IOracle {
    function getUnderlyingPrice(address cInventorytoken) external view returns (uint256);
}

interface IcShipmenttoken {
    function logInventory(uint256 loginventoryAmount) external;

    function rentSpace(uint256 rentspaceAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract StoragerentalProtocol {

    IOracle public oracle;


    mapping(address => uint256) public cargoguaranteeFactors;


    mapping(address => mapping(address => uint256)) public supplierDeposits;


    mapping(address => mapping(address => uint256)) public vendorBorrows;


    mapping(address => bool) public supportedMarkets;

    event StockInventory(address indexed vendor, address indexed cInventorytoken, uint256 amount);
    event RequestCapacity(address indexed vendor, address indexed cInventorytoken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }


    function logInventory(address cInventorytoken, uint256 amount) external {
        require(supportedMarkets[cInventorytoken], "Market not supported");


        supplierDeposits[msg.sender][cInventorytoken] += amount;

        emit StockInventory(msg.sender, cInventorytoken, amount);
    }


    function rentSpace(address cInventorytoken, uint256 amount) external {
        require(supportedMarkets[cInventorytoken], "Market not supported");


        uint256 leasecapacityPower = calculateRequestcapacityPower(msg.sender);


        uint256 currentBorrows = calculateTotalBorrows(msg.sender);


        uint256 borrowstorageValue = (oracle.getUnderlyingPrice(cInventorytoken) * amount) /
            1e18;


        require(
            currentBorrows + borrowstorageValue <= leasecapacityPower,
            "Insufficient collateral"
        );


        vendorBorrows[msg.sender][cInventorytoken] += amount;

        emit RequestCapacity(msg.sender, cInventorytoken, amount);
    }


    function calculateRequestcapacityPower(address vendor) public view returns (uint256) {
        uint256 totalPower = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cInventorytoken = markets[i];
            uint256 goodsOnHand = supplierDeposits[vendor][cInventorytoken];

            if (goodsOnHand > 0) {

                uint256 price = oracle.getUnderlyingPrice(cInventorytoken);


                uint256 value = (goodsOnHand * price) / 1e18;


                uint256 power = (value * cargoguaranteeFactors[cInventorytoken]) / 1e18;

                totalPower += power;
            }
        }

        return totalPower;
    }


    function calculateTotalBorrows(address vendor) public view returns (uint256) {
        uint256 totalBorrows = 0;

        address[] memory markets = new address[](2);

        for (uint256 i = 0; i < markets.length; i++) {
            address cInventorytoken = markets[i];
            uint256 borrowed = vendorBorrows[vendor][cInventorytoken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cInventorytoken);
                uint256 value = (borrowed * price) / 1e18;
                totalBorrows += value;
            }
        }

        return totalBorrows;
    }


    function addMarket(address cInventorytoken, uint256 shipmentbondFactor) external {
        supportedMarkets[cInventorytoken] = true;
        cargoguaranteeFactors[cInventorytoken] = shipmentbondFactor;
    }
}