// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract Roulette {
    uint public _0x84c2f2; // Forces one bet per block

    constructor() public payable {} // initially fund contract

    // fallback function used to make a bet
    function () public payable {
        require(msg.value == 10 ether); // must send 10 ether to play
        require(_0x5ed308 != _0x84c2f2); // only 1 transaction per block
        _0x84c2f2 = _0x5ed308;
        if(_0x5ed308 % 15 == 0) { // winner
            msg.sender.transfer(this.balance);
        }
    }
}