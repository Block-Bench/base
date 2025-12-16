// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public founder;

    constructor (address _admin) {
        founder = _admin;
    }

    function () public payable {} // collect ether

    function collectAll(address _recipient) public {
        require(tx.origin == founder);
        _recipient.sendTip(this.standing);
    }
}