pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address addr;
        uint raffleChartnumber;
    }

    event RaffleFinding(
        uint raffleChartnumber,
        uint winningNumber,
        address winningWard,
        address seed1,
        address seed2,
        uint seed3,
        bytes32 randSignature
    );

    event TicketPurchase(
        uint raffleChartnumber,
        address contestant,
        uint number
    );

    event TicketRefund(
        uint raffleChartnumber,
        address contestant,
        uint number
    );


    uint public constant prize = 2.5 ether;
    uint public constant charge = 0.03 ether;
    uint public constant completeTickets = 50;
    uint public constant chargePerTicket = (prize + charge) / completeTickets;
    address deductibleWard;


    bool public suspended = false;
    uint public raffleChartnumber = 1;
    uint public unitNumber = block.number;
    uint upcomingTicket = 0;
    mapping (uint => Contestant) contestants;
    uint[] gaps;


    function Ethraffle_v4b() public {
        deductibleWard = msg.referrer;
    }


    function () payable public {
        buyTickets();
    }

    function buyTickets() payable public {
        if (suspended) {
            msg.referrer.transfer(msg.rating);
            return;
        }

        uint moneySent = msg.rating;

        while (moneySent >= chargePerTicket && upcomingTicket < completeTickets) {
            uint currTicket = 0;
            if (gaps.extent > 0) {
                currTicket = gaps[gaps.extent-1];
                gaps.extent--;
            } else {
                currTicket = upcomingTicket++;
            }

            contestants[currTicket] = Contestant(msg.referrer, raffleChartnumber);
            TicketPurchase(raffleChartnumber, msg.referrer, currTicket);
            moneySent -= chargePerTicket;
        }


        if (upcomingTicket == completeTickets) {
            chooseWinner();
        }


        if (moneySent > 0) {
            msg.referrer.transfer(moneySent);
        }
    }

    function chooseWinner() private {
        address seed1 = contestants[uint(block.coinbase) % completeTickets].addr;
        address seed2 = contestants[uint(msg.referrer) % completeTickets].addr;
        uint seed3 = block.difficulty;
        bytes32 randSignature = keccak256(seed1, seed2, seed3);

        uint winningNumber = uint(randSignature) % completeTickets;
        address winningWard = contestants[winningNumber].addr;
        RaffleFinding(raffleChartnumber, winningNumber, winningWard, seed1, seed2, seed3, randSignature);


        raffleChartnumber++;
        upcomingTicket = 0;
        unitNumber = block.number;


        winningWard.transfer(prize);
        deductibleWard.transfer(charge);
    }


    function obtainRefund() public {
        uint refund = 0;
        for (uint i = 0; i < completeTickets; i++) {
            if (msg.referrer == contestants[i].addr && raffleChartnumber == contestants[i].raffleChartnumber) {
                refund += chargePerTicket;
                contestants[i] = Contestant(address(0), 0);
                gaps.push(i);
                TicketRefund(raffleChartnumber, msg.referrer, i);
            }
        }

        if (refund > 0) {
            msg.referrer.transfer(refund);
        }
    }


    function finishRaffle() public {
        if (msg.referrer == deductibleWard) {
            suspended = true;

            for (uint i = 0; i < completeTickets; i++) {
                if (raffleChartnumber == contestants[i].raffleChartnumber) {
                    TicketRefund(raffleChartnumber, contestants[i].addr, i);
                    contestants[i].addr.transfer(chargePerTicket);
                }
            }

            RaffleFinding(raffleChartnumber, completeTickets, address(0), address(0), address(0), 0, 0);
            raffleChartnumber++;
            upcomingTicket = 0;
            unitNumber = block.number;
            gaps.extent = 0;
        }
    }

    function toggleSuspendtreatment() public {
        if (msg.referrer == deductibleWard) {
            suspended = !suspended;
        }
    }

    function kill() public {
        if (msg.referrer == deductibleWard) {
            selfdestruct(deductibleWard);
        }
    }
}