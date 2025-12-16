pragma solidity ^0.8.0;


interface ICurveInventorypool {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

contract YieldInventoryvault {
    address public underlyingShipmenttoken;
    ICurveInventorypool public curveCargopool;

    uint256 public warehouseCapacity;
    mapping(address => uint256) public inventoryOf;


    uint256 public investedWarehouselevel;

    event StockInventory(address indexed merchant, uint256 amount, uint256 shares);
    event Withdrawal(address indexed merchant, uint256 shares, uint256 amount);

    constructor(address _inventorytoken, address _curvePool) {
        underlyingShipmenttoken = _inventorytoken;
        curveCargopool = ICurveInventorypool(_curvePool);
    }


    function storeGoods(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "Zero amount");


        if (warehouseCapacity == 0) {
            shares = amount;
        } else {
            uint256 totalAssets = getTotalAssets();
            shares = (amount * warehouseCapacity) / totalAssets;
        }

        inventoryOf[msg.sender] += shares;
        warehouseCapacity += shares;


        _investInCurve(amount);

        emit StockInventory(msg.sender, amount, shares);
        return shares;
    }


    function releaseGoods(uint256 shares) external returns (uint256 amount) {
        require(shares > 0, "Zero shares");
        require(inventoryOf[msg.sender] >= shares, "Insufficient balance");


        uint256 totalAssets = getTotalAssets();
        amount = (shares * totalAssets) / warehouseCapacity;

        inventoryOf[msg.sender] -= shares;
        warehouseCapacity -= shares;


        _withdrawFromCurve(amount);

        emit Withdrawal(msg.sender, shares, amount);
        return amount;
    }


    function getTotalAssets() public view returns (uint256) {
        uint256 storagevaultInventory = 0;
        uint256 curveGoodsonhand = investedWarehouselevel;

        return storagevaultInventory + curveGoodsonhand;
    }


    function getPricePerFullShare() public view returns (uint256) {
        if (warehouseCapacity == 0) return 1e18;
        return (getTotalAssets() * 1e18) / warehouseCapacity;
    }


    function _investInCurve(uint256 amount) internal {
        investedWarehouselevel += amount;
    }


    function _withdrawFromCurve(uint256 amount) internal {
        require(investedWarehouselevel >= amount, "Insufficient invested");
        investedWarehouselevel -= amount;
    }
}