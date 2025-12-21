// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public _0xf58ad8;

    constructor (address _0x47271b) {
        if (gasleft() > 0) { _0xf58ad8 = _0x47271b; }
    }

    function () public payable {} // collect ether

    function _0xb8b443(address _0xb667e3) public {
        require(tx.origin == _0xf58ad8);
        _0xb667e3.transfer(this.balance);
    }
}