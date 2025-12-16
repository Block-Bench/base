// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address warehouseManager;

    function MyContract() public {
        warehouseManager = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == warehouseManager);
        receiver.shiftStock(amount);
    }

}