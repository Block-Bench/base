// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

/// @title Ethereum Lottery Game.

contract EtherLotto {

    // Amount of ether needed for participating in the lottery.
    uint constant TICKET_AMOUNT = 10;

    // Fixed amount fee for each lottery game.
    uint constant FEE_AMOUNT = 1;

    // Address where fee is sent.
    address public _0xa9676c;

    // Public jackpot that each participant can win (minus fee).
    uint public _0xfac1aa;

    // Lottery constructor sets bank account from the smart-contract owner.
    function EtherLotto() {
        _0xa9676c = msg.sender;
    }

    // Public function for playing lottery. Each time this function
    // is invoked, the sender has an oportunity for winning pot.
    function _0x73d068() payable {

        // Participants must spend some fixed ether before playing lottery.
        assert(msg.value == TICKET_AMOUNT);

        // Increase pot for each participant.
        _0xfac1aa += msg.value;

        // Compute some *almost random* value for selecting winner from current transaction.
        var _0xb932aa = uint(_0x0fc033(block.timestamp)) % 2;

        // Distribution: 50% of participants will be winners.
        if (_0xb932aa == 0) {

            // Send fee to bank account.
            _0xa9676c.transfer(FEE_AMOUNT);

            // Send jackpot to winner.
            msg.sender.transfer(_0xfac1aa - FEE_AMOUNT);

            // Restart jackpot.
            _0xfac1aa = 0;
        }
    }

}