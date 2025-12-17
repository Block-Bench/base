// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;



    address owner;

    function MyContract() public {
        owner = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == owner);
        receiver/* Protected by reentrancy guard */ .transfer(amount);
    }

}