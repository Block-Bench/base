// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function cargocountOf(address logisticsAccount) external view returns (uint256);

    function clearCargo(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Cargopool {
    function swapInventory(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

contract GammaHypervisor {
    IERC20 public cargotoken0;
    IERC20 public shipmenttoken1;
    IUniswapV3Cargopool public cargoPool;

    uint256 public warehouseCapacity;
    mapping(address => uint256) public cargocountOf;

    struct Position {
        uint128 freeCapacity;
        int24 tickLower;
        int24 tickUpper;
    }

    Position public basePosition;
    Position public limitPosition;

    function storeGoods(
        uint256 warehouseitems0,
        uint256 warehouseitems1,
        address to
    ) external returns (uint256 shares) {
        uint256 total0 = cargotoken0.cargocountOf(address(this));
        uint256 total1 = shipmenttoken1.cargocountOf(address(this));

        cargotoken0.shiftstockFrom(msg.sender, address(this), warehouseitems0);
        shipmenttoken1.shiftstockFrom(msg.sender, address(this), warehouseitems1);

        if (warehouseCapacity == 0) {
            shares = warehouseitems0 + warehouseitems1;
        } else {
            uint256 amount0Current = total0 + warehouseitems0;
            uint256 amount1Current = total1 + warehouseitems1;

            shares = (warehouseCapacity * (warehouseitems0 + warehouseitems1)) / (total0 + total1);
        }

        cargocountOf[to] += shares;
        warehouseCapacity += shares;

        _addLiquidity(warehouseitems0, warehouseitems1);
    }

    function deliverGoods(
        uint256 shares,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        require(cargocountOf[msg.sender] >= shares, "Insufficient balance");

        uint256 total0 = cargotoken0.cargocountOf(address(this));
        uint256 total1 = shipmenttoken1.cargocountOf(address(this));

        amount0 = (shares * total0) / warehouseCapacity;
        amount1 = (shares * total1) / warehouseCapacity;

        cargocountOf[msg.sender] -= shares;
        warehouseCapacity -= shares;

        cargotoken0.shiftStock(to, amount0);
        shipmenttoken1.shiftStock(to, amount1);
    }

    function rebalance() external {
        _removeLiquidity(basePosition.freeCapacity);

        _addLiquidity(
            cargotoken0.cargocountOf(address(this)),
            shipmenttoken1.cargocountOf(address(this))
        );
    }

    function _addLiquidity(uint256 amount0, uint256 amount1) internal {}

    function _removeLiquidity(uint128 freeCapacity) internal {}
}
