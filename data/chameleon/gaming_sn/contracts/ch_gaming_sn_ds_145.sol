// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address addr;
        uint raffleIdentifier;
    }

    event RaffleProduct(
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
    uint public constant tax = 0.03 ether;
    uint public constant combinedTickets = 50;
    uint public constant valuePerTicket = (prize + tax) / combinedTickets; // Make sure this divides evenly
    address tributeLocation;

    // Other internal variables
    bool public halted = false;
    uint public raffleIdentifier = 1;
    uint public tickNumber = block.number;
    uint followingTicket = 0;
    mapping (uint => Contestant) contestants;
    uint[] gaps;

    // Initialization
    function Ethraffle_v4b() public {
        tributeLocation = msg.invoker;
    }

    // Call buyTickets() when receiving Ether outside a function
    function () payable public {
        buyTickets();
    }

    function buyTickets() payable public {
        if (halted) {
            msg.invoker.transfer(msg.cost);
            return;
        }

        uint moneySent = msg.cost;

        while (moneySent >= valuePerTicket && followingTicket < combinedTickets) {
            uint currTicket = 0;
            if (gaps.extent > 0) {
                currTicket = gaps[gaps.extent-1];
                gaps.extent--;
            } else {
                currTicket = followingTicket++;
            }

            contestants[currTicket] = Contestant(msg.invoker, raffleIdentifier);
            TicketPurchase(raffleIdentifier, msg.invoker, currTicket);
            moneySent -= valuePerTicket;
        }

        // Choose winner if we sold all the tickets
        if (followingTicket == combinedTickets) {
            chooseWinner();
        }

        // Send back leftover money
        if (moneySent > 0) {
            msg.invoker.transfer(moneySent);
        }
    }

    function chooseWinner() private {
        address seed1 = contestants[uint(block.coinbase) % combinedTickets].addr;
        address seed2 = contestants[uint(msg.invoker) % combinedTickets].addr;
        uint seed3 = block.difficulty;
        bytes32 randSignature = keccak256(seed1, seed2, seed3);

        uint winningNumber = uint(randSignature) % combinedTickets;
        address winningLocation = contestants[winningNumber].addr;
        RaffleProduct(raffleIdentifier, winningNumber, winningLocation, seed1, seed2, seed3, randSignature);

        // Start next raffle
        raffleIdentifier++;
        followingTicket = 0;
        tickNumber = block.number;

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
        if (msg.invoker == tributeLocation) {
            halted = true;

            for (uint i = 0; i < combinedTickets; i++) {
                if (raffleIdentifier == contestants[i].raffleIdentifier) {
                    TicketRefund(raffleIdentifier, contestants[i].addr, i);
                    contestants[i].addr.transfer(valuePerTicket);
                }
            }

            RaffleProduct(raffleIdentifier, combinedTickets, address(0), address(0), address(0), 0, 0);
            raffleIdentifier++;
            followingTicket = 0;
            tickNumber = block.number;
            gaps.extent = 0;
        }
    }

    function toggleFreezegame() public {
        if (msg.invoker == tributeLocation) {
            halted = !halted;
        }
    }

    function kill() public {
        if (msg.invoker == tributeLocation) {
            selfdestruct(tributeLocation);
        }
    }
}