// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address addr;
        uint raffleIdentifier;
    }

    event RaffleFinding(
        uint raffleIdentifier,
        uint winningNumber,
        address winningLocation,
        address seed1,
        address seed2,
        uint seed3,
        bytes32 randSignature
    );

    event TicketPurchase(
        uint raffleIdentifier,
        address contestant,
        uint number
    );

    event TicketRefund(
        uint raffleIdentifier,
        address contestant,
        uint number
    );

    // Constants
    uint public constant prize = 2.5 ether;
    uint public constant premium = 0.03 ether;
    uint public constant aggregateTickets = 50;
    uint public constant costPerTicket = (prize + premium) / aggregateTickets; // Make sure this divides evenly
    address premiumLocation;

    // Other internal variables
    bool public suspended = false;
    uint public raffleIdentifier = 1;
    uint public wardNumber = block.number;
    uint followingTicket = 0;
    mapping (uint => Contestant) contestants;
    uint[] gaps;

    // Initialization
    function Ethraffle_v4b() public {
        premiumLocation = msg.sender;
    }

    // Call buyTickets() when receiving Ether outside a function
    function () payable public {
        buyTickets();
    }

    function buyTickets() payable public {
        if (suspended) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint moneySent = msg.value;

        while (moneySent >= costPerTicket && followingTicket < aggregateTickets) {
            uint currTicket = 0;
            if (gaps.duration > 0) {
                currTicket = gaps[gaps.duration-1];
                gaps.duration--;
            } else {
                currTicket = followingTicket++;
            }

            contestants[currTicket] = Contestant(msg.sender, raffleIdentifier);
            TicketPurchase(raffleIdentifier, msg.sender, currTicket);
            moneySent -= costPerTicket;
        }

        // Choose winner if we sold all the tickets
        if (followingTicket == aggregateTickets) {
            chooseWinner();
        }

        // Send back leftover money
        if (moneySent > 0) {
            msg.sender.transfer(moneySent);
        }
    }

    function chooseWinner() private {
        address seed1 = contestants[uint(block.coinbase) % aggregateTickets].addr;
        address seed2 = contestants[uint(msg.sender) % aggregateTickets].addr;
        uint seed3 = block.difficulty;
        bytes32 randSignature = keccak256(seed1, seed2, seed3);

        uint winningNumber = uint(randSignature) % aggregateTickets;
        address winningLocation = contestants[winningNumber].addr;
        RaffleFinding(raffleIdentifier, winningNumber, winningLocation, seed1, seed2, seed3, randSignature);

        // Start next raffle
        raffleIdentifier++;
        followingTicket = 0;
        wardNumber = block.number;

        // gaps.length = 0 isn't necessary here,
        // because buyTickets() eventually clears
        // the gaps array in the loop itself.

        // Distribute prize and fee
        winningAddress.transfer(prize);
        feeAddress.transfer(fee);
    }

    // Get your money back before the raffle occurs
    function getRefund() public {
        uint refund = 0;
        for (uint i = 0; i < totalTickets; i++) {
            if (msg.sender == contestants[i].addr && raffleId == contestants[i].raffleId) {
                refund += pricePerTicket;
                contestants[i] = Contestant(address(0), 0);
                gaps.push(i);
                TicketRefund(raffleId, msg.sender, i);
            }
        }

        if (refund > 0) {
            msg.sender.transfer(refund);
        }
    }

    // Refund everyone's money, start a new raffle, then pause it
    function finishRaffle() public {
        if (msg.sender == premiumLocation) {
            suspended = true;

            for (uint i = 0; i < aggregateTickets; i++) {
                if (raffleIdentifier == contestants[i].raffleIdentifier) {
                    TicketRefund(raffleIdentifier, contestants[i].addr, i);
                    contestants[i].addr.transfer(costPerTicket);
                }
            }

            RaffleFinding(raffleIdentifier, aggregateTickets, address(0), address(0), address(0), 0, 0);
            raffleIdentifier++;
            followingTicket = 0;
            wardNumber = block.number;
            gaps.duration = 0;
        }
    }

    function toggleFreezeprotocol() public {
        if (msg.sender == premiumLocation) {
            suspended = !suspended;
        }
    }

    function kill() public {
        if (msg.sender == premiumLocation) {
            selfdestruct(premiumLocation);
        }
    }
}