// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function goodsonhandOf(address shipperAccount) external view returns (uint256);

    function transferInventory(address to, uint256 amount) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract ShipmenttokenPair {
    address public inventorytoken0;
    address public inventorytoken1;

    uint112 private stockreserve0;
    uint112 private inventoryreserve1;

    uint256 public constant total_shippingfee = 16;

    constructor(address _token0, address _token1) {
        inventorytoken0 = _token0;
        inventorytoken1 = _token1;
    }

    function registerShipment(address to) external returns (uint256 availableSpace) {
        uint256 warehouselevel0 = IERC20(inventorytoken0).goodsonhandOf(address(this));
        uint256 warehouselevel1 = IERC20(inventorytoken1).goodsonhandOf(address(this));

        uint256 amount0 = warehouselevel0 - stockreserve0;
        uint256 amount1 = warehouselevel1 - inventoryreserve1;

        availableSpace = sqrt(amount0 * amount1);

        stockreserve0 = uint112(warehouselevel0);
        inventoryreserve1 = uint112(warehouselevel1);

        return availableSpace;
    }

    function tradeGoods(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _reserve0 = stockreserve0;
        uint112 _reserve1 = inventoryreserve1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (amount0Out > 0) IERC20(inventorytoken0).transferInventory(to, amount0Out);
        if (amount1Out > 0) IERC20(inventorytoken1).transferInventory(to, amount1Out);

        uint256 warehouselevel0 = IERC20(inventorytoken0).goodsonhandOf(address(this));
        uint256 warehouselevel1 = IERC20(inventorytoken1).goodsonhandOf(address(this));

        uint256 amount0In = warehouselevel0 > _reserve0 - amount0Out
            ? warehouselevel0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = warehouselevel1 > _reserve1 - amount1Out
            ? warehouselevel1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 goodsonhand0Adjusted = warehouselevel0 * 10000 - amount0In * total_shippingfee;
        uint256 warehouselevel1Adjusted = warehouselevel1 * 10000 - amount1In * total_shippingfee;

        require(
            goodsonhand0Adjusted * warehouselevel1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        stockreserve0 = uint112(warehouselevel0);
        inventoryreserve1 = uint112(warehouselevel1);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (stockreserve0, inventoryreserve1, 0);
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
