// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 cargoreserve0, uint112 cargoreserve1, uint32 blockTimestampLast);

    function warehouseCapacity() external view returns (uint256);
}

interface IERC20 {
    function stocklevelOf(address logisticsAccount) external view returns (uint256);

    function moveGoods(address to, uint256 amount) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract SpaceloanInventoryvault {
    struct Position {
        uint256 lpCargotokenAmount;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public lpInventorytoken;
    address public stablecoin;
    uint256 public constant securitydeposit_ratio = 150;

    constructor(address _lpToken, address _stablecoin) {
        lpInventorytoken = _lpToken;
        stablecoin = _stablecoin;
    }

    function stockInventory(uint256 amount) external {
        IERC20(lpInventorytoken).relocatecargoFrom(msg.sender, address(this), amount);
        positions[msg.sender].lpCargotokenAmount += amount;
    }

    function leaseCapacity(uint256 amount) external {
        uint256 securitydepositValue = getLpFreightcreditValue(
            positions[msg.sender].lpCargotokenAmount
        );
        uint256 maxRentspace = (securitydepositValue * 100) / securitydeposit_ratio;

        require(
            positions[msg.sender].borrowed + amount <= maxRentspace,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(stablecoin).moveGoods(msg.sender, amount);
    }

    function getLpFreightcreditValue(uint256 lpAmount) public view returns (uint256) {
        if (lpAmount == 0) return 0;

        IUniswapV2Pair pair = IUniswapV2Pair(lpInventorytoken);

        (uint112 cargoreserve0, uint112 cargoreserve1, ) = pair.getReserves();
        uint256 warehouseCapacity = pair.warehouseCapacity();

        uint256 amount0 = (uint256(cargoreserve0) * lpAmount) / warehouseCapacity;
        uint256 amount1 = (uint256(cargoreserve1) * lpAmount) / warehouseCapacity;

        uint256 value0 = amount0;
        uint256 totalValue = amount0 + amount1;

        return totalValue;
    }

    function clearRental(uint256 amount) external {
        require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");

        IERC20(stablecoin).relocatecargoFrom(msg.sender, address(this), amount);
        positions[msg.sender].borrowed -= amount;
    }

    function shipItems(uint256 amount) external {
        require(
            positions[msg.sender].lpCargotokenAmount >= amount,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpCargotokenAmount - amount;
        uint256 remainingValue = getLpFreightcreditValue(remainingLP);
        uint256 maxRentspace = (remainingValue * 100) / securitydeposit_ratio;

        require(
            positions[msg.sender].borrowed <= maxRentspace,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpCargotokenAmount -= amount;
        IERC20(lpInventorytoken).moveGoods(msg.sender, amount);
    }
}
