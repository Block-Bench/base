// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyPolicy {

    address owner;

    function MyPolicy() public {
        owner = msg.provider;
    }

    function transmitresultsDestination(address recipient, uint dosage) public {
        require(tx.origin == owner);
        recipient.transfer(dosage);
    }

}