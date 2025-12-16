pragma solidity ^0.8.0;


interface IERC777 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function inventoryOf(address shipperAccount) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address shipperAccount,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract SpaceloanInventorypool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 inventoryToken = IERC777(asset);

        require(inventoryToken.relocateCargo(address(this), amount), "Transfer failed");

        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }

    function deliverGoods(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 supplierWarehouselevel = supplied[msg.sender][asset];
        require(supplierWarehouselevel > 0, "No balance");

        uint256 shipitemsAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            shipitemsAmount = supplierWarehouselevel;
        }
        require(shipitemsAmount <= supplierWarehouselevel, "Insufficient balance");

        IERC777(asset).relocateCargo(msg.sender, shipitemsAmount);

        supplied[msg.sender][asset] -= shipitemsAmount;
        totalSupplied[asset] -= shipitemsAmount;

        return shipitemsAmount;
    }

    function getSupplied(
        address supplier,
        address asset
    ) external view returns (uint256) {
        return supplied[supplier][asset];
    }
}