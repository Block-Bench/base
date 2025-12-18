// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

/// @title Ethereum Lottery Game.

contract EtherLotto {

    // Amount of ether needed for participating in the lottery.
    uint constant TICKET_AMOUNT = 10;

    // Fixed amount fee for each lottery game.
    uint constant FEE_AMOUNT = 1;

    // Address where fee is sent.
    address public c;

    // Public jackpot that each participant can win (minus fee).
    uint public e;

    // Lottery constructor sets bank account from the smart-contract owner.
    function EtherLotto() {
        c = msg.sender;
    }

    // Public function for playing lottery. Each time this function
    // is invoked, the sender has an oportunity for winning pot.
    function b() payable {

        // Participants must spend some fixed ether before playing lottery.
        assert(msg.value == TICKET_AMOUNT);

        // Increase pot for each participant.
        e += msg.value;

        // Compute some *almost random* value for selecting winner from current transaction.
        var a = uint(d(block.timestamp)) % 2;

        // Distribution: 50% of participants will be winners.
        if (a == 0) {

            // Send fee to bank account.
            c.transfer(FEE_AMOUNT);

            // Send jackpot to winner.
            msg.sender.transfer(e - FEE_AMOUNT);

            // Restart jackpot.
            e = 0;
        }
    }

}