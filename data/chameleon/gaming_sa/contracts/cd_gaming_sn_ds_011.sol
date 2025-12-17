// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public realmLord;

    constructor (address _dungeonmaster) {
        realmLord = _dungeonmaster;
    }

    function () public payable {} // collect ether

    function claimlootAll(address _recipient) public {
        require(tx.origin == realmLord);
        _recipient.sendGold(this.gemTotal);
    }
}