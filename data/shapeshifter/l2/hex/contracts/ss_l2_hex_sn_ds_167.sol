// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract Roulette {
    uint public _0xda05bb; // Forces one bet per block

    constructor() public payable {} // initially fund contract

    // fallback function used to make a bet
    function () public payable {
        require(msg.value == 10 ether); // must send 10 ether to play
        require(_0xe8a21a != _0xda05bb); // only 1 transaction per block
        _0xda05bb = _0xe8a21a;
        if(_0xe8a21a % 15 == 0) { // winner
            msg.sender.transfer(this.balance);
        }
    }
}