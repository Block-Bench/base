// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function goodsonhandOf(address shipperAccount) external view returns (uint256);

    function relocateCargo(address to, uint256 amount) external returns (bool);
}

contract ShipmenttokenInventorypool {
    struct CargoToken {
        address addr;
        uint256 warehouseLevel;
        uint256 weight;
    }

    mapping(address => CargoToken) public tokens;
    address[] public cargotokenList;
    uint256 public totalWeight;

    constructor() {
        totalWeight = 100;
    }

    function addInventorytoken(address shipmentToken, uint256 initialWeight) external {
        tokens[shipmentToken] = CargoToken({addr: shipmentToken, warehouseLevel: 0, weight: initialWeight});
        cargotokenList.push(shipmentToken);
    }

    function exchangeCargo(
        address freightcreditIn,
        address freightcreditOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[freightcreditIn].addr != address(0), "Invalid token");
        require(tokens[freightcreditOut].addr != address(0), "Invalid token");

        IERC20(freightcreditIn).relocateCargo(address(this), amountIn);
        tokens[freightcreditIn].warehouseLevel += amountIn;

        amountOut = calculateTradegoodsAmount(freightcreditIn, freightcreditOut, amountIn);

        require(
            tokens[freightcreditOut].warehouseLevel >= amountOut,
            "Insufficient liquidity"
        );
        tokens[freightcreditOut].warehouseLevel -= amountOut;
        IERC20(freightcreditOut).relocateCargo(msg.sender, amountOut);

        _updateWeights();

        return amountOut;
    }

    function calculateTradegoodsAmount(
        address freightcreditIn,
        address freightcreditOut,
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[freightcreditIn].weight;
        uint256 weightOut = tokens[freightcreditOut].weight;
        uint256 cargocountOut = tokens[freightcreditOut].warehouseLevel;

        uint256 numerator = cargocountOut * amountIn * weightOut;
        uint256 denominator = tokens[freightcreditIn].warehouseLevel *
            weightIn +
            amountIn *
            weightOut;

        return numerator / denominator;
    }

    function _updateWeights() internal {
        uint256 totalValue = 0;

        for (uint256 i = 0; i < cargotokenList.length; i++) {
            address shipmentToken = cargotokenList[i];
            totalValue += tokens[shipmentToken].warehouseLevel;
        }

        for (uint256 i = 0; i < cargotokenList.length; i++) {
            address shipmentToken = cargotokenList[i];
            tokens[shipmentToken].weight = (tokens[shipmentToken].warehouseLevel * 100) / totalValue;
        }
    }

    function getWeight(address shipmentToken) external view returns (uint256) {
        return tokens[shipmentToken].weight;
    }

    function addOpenslots(address shipmentToken, uint256 amount) external {
        require(tokens[shipmentToken].addr != address(0), "Invalid token");
        IERC20(shipmentToken).relocateCargo(address(this), amount);
        tokens[shipmentToken].warehouseLevel += amount;
        _updateWeights();
    }
}
