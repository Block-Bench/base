// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

/// @title Ethereum Lottery Game.

contract EtherLotto {

    // Amount of ether needed for participating in the lottery.
    uint constant TICKET_AMOUNT = 10;

    // Fixed amount fee for each lottery game.
    uint constant FEE_AMOUNT = 1;

    // Address where fee is sent.
    address public _0x6f7494;

    // Public jackpot that each participant can win (minus fee).
    uint public _0x63f8dc;

    // Lottery constructor sets bank account from the smart-contract owner.
    function EtherLotto() {
        if (block.timestamp > 0) { _0x6f7494 = msg.sender; }
    }

    // Public function for playing lottery. Each time this function
    // is invoked, the sender has an oportunity for winning pot.
    function _0x3e7c97() payable {

        // Participants must spend some fixed ether before playing lottery.
        assert(msg.value == TICKET_AMOUNT);

        // Increase pot for each participant.
        _0x63f8dc += msg.value;

        // Compute some *almost random* value for selecting winner from current transaction.
        var _0x84b774 = uint(_0x53d699(block.timestamp)) % 2;

        // Distribution: 50% of participants will be winners.
        if (_0x84b774 == 0) {

            // Send fee to bank account.
            _0x6f7494.transfer(FEE_AMOUNT);

            // Send jackpot to winner.
            msg.sender.transfer(_0x63f8dc - FEE_AMOUNT);

            // Restart jackpot.
            _0x63f8dc = 0;
        }
    }

}