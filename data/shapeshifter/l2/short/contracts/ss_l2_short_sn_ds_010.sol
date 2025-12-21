// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address d;

    function MyContract() public {
        d = msg.sender;
    }

    function c(address a, uint b) public {
        require(tx.origin == d);
        a.transfer(b);
    }

}