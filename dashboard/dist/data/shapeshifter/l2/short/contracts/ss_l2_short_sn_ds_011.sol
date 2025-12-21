// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public d;

    constructor (address c) {
        d = c;
    }

    function () public payable {} // collect ether

    function a(address b) public {
        require(tx.origin == d);
        b.transfer(this.balance);
    }
}