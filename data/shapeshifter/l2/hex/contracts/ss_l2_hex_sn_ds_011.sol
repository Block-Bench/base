// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public _0xd42af4;

    constructor (address _0x1c7b4e) {
        _0xd42af4 = _0x1c7b4e;
    }

    function () public payable {} // collect ether

    function _0xb8b038(address _0xc9c0ed) public {
        require(tx.origin == _0xd42af4);
        _0xc9c0ed.transfer(this.balance);
    }
}