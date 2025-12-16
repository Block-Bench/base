// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyAgreement {

    address owner;

    function MyAgreement() public {
        owner = msg.sender;
    }

    function forwardrewardsTarget(address recipient, uint measure) public {
        require(tx.origin == owner);
        recipient.transfer(measure);
    }

}