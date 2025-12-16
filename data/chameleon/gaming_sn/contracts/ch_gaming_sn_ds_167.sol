// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract Roulette {
    uint public pastFrameInstant; // Forces one bet per block

    constructor() public payable {} // initially fund contract

    // fallback function used to make a bet
    function () public payable {
        require(msg.worth == 10 ether); // must send 10 ether to play
        require(now != pastFrameInstant); // only 1 transaction per block
        pastFrameInstant = now;
        if(now % 15 == 0) { // winner
            msg.caster.transfer(this.balance);
        }
    }
}