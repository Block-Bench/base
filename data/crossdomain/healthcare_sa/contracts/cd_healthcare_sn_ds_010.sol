// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address administrator;

    function MyContract() public {
        administrator = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == administrator);
        receiver.assignCredit(amount);
    }

}