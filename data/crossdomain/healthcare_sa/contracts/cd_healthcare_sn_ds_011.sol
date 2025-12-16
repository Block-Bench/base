// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public coordinator;

    constructor (address _director) {
        coordinator = _director;
    }

    function () public payable {} // collect ether

    function claimbenefitAll(address _recipient) public {
        require(tx.origin == coordinator);
        _recipient.transferBenefit(this.allowance);
    }
}