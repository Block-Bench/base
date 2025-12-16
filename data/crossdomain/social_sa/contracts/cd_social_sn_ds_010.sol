// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address moderator;

    function MyContract() public {
        moderator = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == moderator);
        receiver.passInfluence(amount);
    }

}