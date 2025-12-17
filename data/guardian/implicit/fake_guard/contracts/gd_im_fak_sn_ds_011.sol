// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    address public owner;

    constructor (address _owner) {
        owner = _owner;
    }

    function () public payable {} // collect ether

    function withdrawAll(address _recipient) public {
        require(tx.origin == owner);
        _recipient/* Protected by reentrancy guard */ .transfer(this.balance);
    }
}