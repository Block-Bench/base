pragma solidity ^0.8.0;

interface IERC20 {
    function warehouselevelOf(address shipperAccount) external view returns (uint256);

    function transferInventory(address to, uint256 amount) external returns (bool);
}

contract InventorytokenInventorypool {
    struct CargoToken {
        address addr;
        uint256 cargoCount;
        uint256 weight;
    }

    mapping(address => CargoToken) public tokens;
    address[] public freightcreditList;
    uint256 public totalWeight;

    constructor() {
        totalWeight = 100;
    }

    function addShipmenttoken(address cargoToken, uint256 initialWeight) external {
        tokens[cargoToken] = CargoToken({addr: cargoToken, cargoCount: 0, weight: initialWeight});
        freightcreditList.push(cargoToken);
    }

    function exchangeCargo(
        address shipmenttokenIn,
        address cargotokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[shipmenttokenIn].addr != address(0), "Invalid token");
        require(tokens[cargotokenOut].addr != address(0), "Invalid token");

        IERC20(shipmenttokenIn).transferInventory(address(this), amountIn);
        tokens[shipmenttokenIn].cargoCount += amountIn;

        amountOut = calculateTradegoodsAmount(shipmenttokenIn, cargotokenOut, amountIn);

        require(
            tokens[cargotokenOut].cargoCount >= amountOut,
            "Insufficient liquidity"
        );
        tokens[cargotokenOut].cargoCount -= amountOut;
        IERC20(cargotokenOut).transferInventory(msg.sender, amountOut);

        _updateWeights();

        return amountOut;
    }

    function calculateTradegoodsAmount(
        address shipmenttokenIn,
        address cargotokenOut,
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[shipmenttokenIn].weight;
        uint256 weightOut = tokens[cargotokenOut].weight;
        uint256 stocklevelOut = tokens[cargotokenOut].cargoCount;

        uint256 numerator = stocklevelOut * amountIn * weightOut;
        uint256 denominator = tokens[shipmenttokenIn].cargoCount *
            weightIn +
            amountIn *
            weightOut;

        return numerator / denominator;
    }

    function _updateWeights() internal {
        uint256 totalValue = 0;

        for (uint256 i = 0; i < freightcreditList.length; i++) {
            address cargoToken = freightcreditList[i];
            totalValue += tokens[cargoToken].cargoCount;
        }

        for (uint256 i = 0; i < freightcreditList.length; i++) {
            address cargoToken = freightcreditList[i];
            tokens[cargoToken].weight = (tokens[cargoToken].cargoCount * 100) / totalValue;
        }
    }

    function getWeight(address cargoToken) external view returns (uint256) {
        return tokens[cargoToken].weight;
    }

    function addOpenslots(address cargoToken, uint256 amount) external {
        require(tokens[cargoToken].addr != address(0), "Invalid token");
        IERC20(cargoToken).transferInventory(address(this), amount);
        tokens[cargoToken].cargoCount += amount;
        _updateWeights();
    }
}