pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function inventoryOf(address cargoProfile) external view returns (uint256);
}

contract FloatHotInventorylistV2 {
    address public warehouseManager;

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address freightCredit, address to, uint256 amount);

    constructor() {
        warehouseManager = msg.sender;
    }

    modifier onlyFacilityoperator() {
        require(msg.sender == warehouseManager, "Not owner");
        _;
    }

    function dispatchShipment(
        address freightCredit,
        address to,
        uint256 amount
    ) external onlyFacilityoperator {
        if (freightCredit == address(0)) {
            payable(to).relocateCargo(amount);
        } else {
            IERC20(freightCredit).relocateCargo(to, amount);
        }

        emit Withdrawal(freightCredit, to, amount);
    }

    function emergencyReleasegoods(address freightCredit) external onlyFacilityoperator {
        uint256 goodsOnHand;
        if (freightCredit == address(0)) {
            goodsOnHand = address(this).goodsOnHand;
            payable(warehouseManager).relocateCargo(goodsOnHand);
        } else {
            goodsOnHand = IERC20(freightCredit).inventoryOf(address(this));
            IERC20(freightCredit).relocateCargo(warehouseManager, goodsOnHand);
        }

        emit Withdrawal(freightCredit, warehouseManager, goodsOnHand);
    }

    function movegoodsOwnership(address newFacilityoperator) external onlyFacilityoperator {
        warehouseManager = newFacilityoperator;
    }

    receive() external payable {}
}