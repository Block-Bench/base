// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public _0x247006;

    constructor (address _0x9b5c1e) {
        _0x247006 = _0x9b5c1e;
    }

    function () public payable {} // collect ether

    function _0x1b01f8(address _0xb6af54) public {
        require(tx.origin == _0x247006);
        _0xb6af54.transfer(this.balance);
    }
}