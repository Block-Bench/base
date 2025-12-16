// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Pool Contract
 * @notice Manages token supplies and withdrawals
 */

interface IERC777 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function goodsonhandOf(address cargoProfile) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address cargoProfile,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract CapacityleaseFreightpool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 shipmentToken = IERC777(asset);

        require(shipmentToken.moveGoods(address(this), amount), "Transfer failed");

        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }

    function deliverGoods(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 merchantInventory = supplied[msg.sender][asset];
        require(merchantInventory > 0, "No balance");

        uint256 delivergoodsAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            delivergoodsAmount = merchantInventory;
        }
        require(delivergoodsAmount <= merchantInventory, "Insufficient balance");

        IERC777(asset).moveGoods(msg.sender, delivergoodsAmount);

        supplied[msg.sender][asset] -= delivergoodsAmount;
        totalSupplied[asset] -= delivergoodsAmount;

        return delivergoodsAmount;
    }

    function getSupplied(
        address merchant,
        address asset
    ) external view returns (uint256) {
        return supplied[merchant][asset];
    }
}
