// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract Roulette {
    uint public a; // Forces one bet per block

    constructor() public payable {} // initially fund contract

    // fallback function used to make a bet
    function () public payable {
        require(msg.value == 10 ether); // must send 10 ether to play
        require(b != a); // only 1 transaction per block
        a = b;
        if(b % 15 == 0) { // winner
            msg.sender.transfer(this.balance);
        }
    }
}