pragma solidity ^0.8.0;

interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goodsonhandOf(address shipperAccount) external view returns (uint256);

    function authorizeShipment(address spender, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address inventoryToken) external view returns (uint256);
}

contract BlueberryCapacitylease {
    struct Market {
        bool isListed;
        uint256 securitydepositFactor;
        mapping(address => uint256) logisticsaccountSecuritydeposit;
        mapping(address => uint256) shipperaccountBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant shipmentbond_factor = 75;
    uint256 public constant BASIS_POINTS = 100;

    function enterMarkets(
        address[] calldata vTokens
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vTokens.length);
        for (uint256 i = 0; i < vTokens.length; i++) {
            markets[vTokens[i]].isListed = true;
            results[i] = 0;
        }
        return results;
    }

    function logInventory(address inventoryToken, uint256 amount) external returns (uint256) {
        IERC20(inventoryToken).relocatecargoFrom(msg.sender, address(this), amount);

        uint256 price = oracle.getPrice(inventoryToken);

        markets[inventoryToken].logisticsaccountSecuritydeposit[msg.sender] += amount;
        return 0;
    }

    function requestCapacity(
        address rentspaceShipmenttoken,
        uint256 rentspaceAmount
    ) external returns (uint256) {
        uint256 totalSecuritydepositValue = 0;

        uint256 leasecapacityPrice = oracle.getPrice(rentspaceShipmenttoken);
        uint256 leasecapacityValue = (rentspaceAmount * leasecapacityPrice) / 1e18;

        uint256 maxRequestcapacityValue = (totalSecuritydepositValue * shipmentbond_factor) /
            BASIS_POINTS;

        require(leasecapacityValue <= maxRequestcapacityValue, "Insufficient collateral");

        markets[rentspaceShipmenttoken].shipperaccountBorrows[msg.sender] += rentspaceAmount;
        IERC20(rentspaceShipmenttoken).moveGoods(msg.sender, rentspaceAmount);

        return 0;
    }

    function auctionGoods(
        address spaceLeaser,
        address clearrentalCargotoken,
        uint256 clearrentalAmount,
        address insurancebondInventorytoken
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    function getPrice(address inventoryToken) external view override returns (uint256) {
        return prices[inventoryToken];
    }

    function setPrice(address inventoryToken, uint256 price) external {
        prices[inventoryToken] = price;
    }
}