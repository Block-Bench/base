// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public depotOwner;

    constructor (address _facilityoperator) {
        depotOwner = _facilityoperator;
    }

    function () public payable {} // collect ether

    function releasegoodsAll(address _recipient) public {
        require(tx.origin == depotOwner);
        _recipient.moveGoods(this.goodsOnHand);
    }
}