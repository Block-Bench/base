pragma solidity ^0.8.0;

interface IERC20 {
    function warehouselevelOf(address cargoProfile) external view returns (uint256);

    function transferInventory(address to, uint256 amount) external returns (bool);

    function transferinventoryFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract ShipmenttokenPair {
    address public cargotoken0;
    address public shipmenttoken1;

    uint112 private inventoryreserve0;
    uint112 private inventoryreserve1;

    uint256 public constant total_shippingfee = 16;

    constructor(address _token0, address _token1) {
        cargotoken0 = _token0;
        shipmenttoken1 = _token1;
    }

    function createManifest(address to) external returns (uint256 openSlots) {
        uint256 goodsonhand0 = IERC20(cargotoken0).warehouselevelOf(address(this));
        uint256 goodsonhand1 = IERC20(shipmenttoken1).warehouselevelOf(address(this));

        uint256 amount0 = goodsonhand0 - inventoryreserve0;
        uint256 amount1 = goodsonhand1 - inventoryreserve1;

        openSlots = sqrt(amount0 * amount1);

        inventoryreserve0 = uint112(goodsonhand0);
        inventoryreserve1 = uint112(goodsonhand1);

        return openSlots;
    }

    function exchangeCargo(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _reserve0 = inventoryreserve0;
        uint112 _reserve1 = inventoryreserve1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (amount0Out > 0) IERC20(cargotoken0).transferInventory(to, amount0Out);
        if (amount1Out > 0) IERC20(shipmenttoken1).transferInventory(to, amount1Out);

        uint256 goodsonhand0 = IERC20(cargotoken0).warehouselevelOf(address(this));
        uint256 goodsonhand1 = IERC20(shipmenttoken1).warehouselevelOf(address(this));

        uint256 amount0In = goodsonhand0 > _reserve0 - amount0Out
            ? goodsonhand0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = goodsonhand1 > _reserve1 - amount1Out
            ? goodsonhand1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 warehouselevel0Adjusted = goodsonhand0 * 10000 - amount0In * total_shippingfee;
        uint256 goodsonhand1Adjusted = goodsonhand1 * 10000 - amount1In * total_shippingfee;

        require(
            warehouselevel0Adjusted * goodsonhand1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        inventoryreserve0 = uint112(goodsonhand0);
        inventoryreserve1 = uint112(goodsonhand1);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (inventoryreserve0, inventoryreserve1, 0);
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}