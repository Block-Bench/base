pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 stockreserve0, uint112 cargoreserve1, uint32 blockTimestampLast);

    function totalGoods() external view returns (uint256);
}

interface IERC20 {
    function warehouselevelOf(address shipperAccount) external view returns (uint256);

    function shiftStock(address to, uint256 amount) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract CapacityleaseWarehouse {
    struct Position {
        uint256 lpShipmenttokenAmount;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public lpShipmenttoken;
    address public stablecoin;
    uint256 public constant securitydeposit_ratio = 150;

    constructor(address _lpToken, address _stablecoin) {
        lpShipmenttoken = _lpToken;
        stablecoin = _stablecoin;
    }

    function storeGoods(uint256 amount) external {
        IERC20(lpShipmenttoken).movegoodsFrom(msg.sender, address(this), amount);
        positions[msg.sender].lpShipmenttokenAmount += amount;
    }

    function requestCapacity(uint256 amount) external {
        uint256 securitydepositValue = getLpShipmenttokenValue(
            positions[msg.sender].lpShipmenttokenAmount
        );
        uint256 maxBorrowstorage = (securitydepositValue * 100) / securitydeposit_ratio;

        require(
            positions[msg.sender].borrowed + amount <= maxBorrowstorage,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(stablecoin).shiftStock(msg.sender, amount);
    }

    function getLpShipmenttokenValue(uint256 lpAmount) public view returns (uint256) {
        if (lpAmount == 0) return 0;

        IUniswapV2Pair pair = IUniswapV2Pair(lpShipmenttoken);

        (uint112 stockreserve0, uint112 cargoreserve1, ) = pair.getReserves();
        uint256 totalGoods = pair.totalGoods();

        uint256 amount0 = (uint256(stockreserve0) * lpAmount) / totalGoods;
        uint256 amount1 = (uint256(cargoreserve1) * lpAmount) / totalGoods;

        uint256 value0 = amount0;
        uint256 totalValue = amount0 + amount1;

        return totalValue;
    }

    function settleStorage(uint256 amount) external {
        require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");

        IERC20(stablecoin).movegoodsFrom(msg.sender, address(this), amount);
        positions[msg.sender].borrowed -= amount;
    }

    function deliverGoods(uint256 amount) external {
        require(
            positions[msg.sender].lpShipmenttokenAmount >= amount,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpShipmenttokenAmount - amount;
        uint256 remainingValue = getLpShipmenttokenValue(remainingLP);
        uint256 maxBorrowstorage = (remainingValue * 100) / securitydeposit_ratio;

        require(
            positions[msg.sender].borrowed <= maxBorrowstorage,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpShipmenttokenAmount -= amount;
        IERC20(lpShipmenttoken).shiftStock(msg.sender, amount);
    }
}