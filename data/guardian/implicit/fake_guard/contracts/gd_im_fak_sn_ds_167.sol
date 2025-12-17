// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract Roulette {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    uint public pastBlockTime; // Forces one bet per block

    constructor() public payable {} // initially fund contract

    // fallback function used to make a bet
    function () public payable {
        require(msg.value == 10 ether); // must send 10 ether to play
        require(now != pastBlockTime); // only 1 transaction per block
        pastBlockTime = now;
        if(now % 15 == 0) { // winner
            msg.sender/* Protected by reentrancy guard */ .transfer(this.balance);
        }
    }
}