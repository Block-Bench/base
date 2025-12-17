// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address gamemaster;

    function MyContract() public {
        gamemaster = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == gamemaster);
        receiver.shareTreasure(amount);
    }

}