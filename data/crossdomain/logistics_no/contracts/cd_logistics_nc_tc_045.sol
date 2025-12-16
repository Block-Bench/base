pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goodsonhandOf(address cargoProfile) external view returns (uint256);

    function permitRelease(address spender, uint256 amount) external returns (bool);
}

interface IPendleMarket {
    function getDeliverybonusTokens() external view returns (address[] memory);

    function efficiencyrewardIndexesCurrent() external returns (uint256[] memory);

    function collectshipmentRewards(address consignee) external returns (uint256[] memory);
}

contract PenpieCapacityreservation {
    mapping(address => mapping(address => uint256)) public vendorBalances;
    mapping(address => uint256) public totalStaked;

    function stockInventory(address market, uint256 amount) external {
        IERC20(market).movegoodsFrom(msg.sender, address(this), amount);
        vendorBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;
    }

    function collectshipmentRewards(address market, address consignee) external {
        uint256[] memory rewards = IPendleMarket(market).collectshipmentRewards(consignee);

        for (uint256 i = 0; i < rewards.length; i++) {}
    }

    function dispatchShipment(address market, uint256 amount) external {
        require(
            vendorBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        vendorBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        IERC20(market).relocateCargo(msg.sender, amount);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    function registerMarket(address market) external {
        registeredMarkets[market] = true;
    }
}