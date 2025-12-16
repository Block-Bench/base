pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address addr;
        uint raffleTag;
    }

    event RaffleOutcome(
        uint raffleTag,
        uint winningNumber,
        address winningRealm,
        address seed1,
        address seed2,
        uint seed3,
        bytes32 randSeal
    );

    event TicketPurchase(
        uint raffleTag,
        address contestant,
        uint number
    );

    event TicketRefund(
        uint raffleTag,
        address contestant,
        uint number
    );


    uint public constant prize = 2.5 ether;
    uint public constant charge = 0.03 ether;
    uint public constant combinedTickets = 50;
    uint public constant costPerTicket = (prize + charge) / combinedTickets;
    address cutRealm;


    bool public halted = false;
    uint public raffleTag = 1;
    uint public frameNumber = block.number;
    uint upcomingTicket = 0;
    mapping (uint => Contestant) contestants;
    uint[] gaps;


    function Ethraffle_v4b() public {
        cutRealm = msg.sender;
    }


    function () payable public {
        buyTickets();
    }

    function buyTickets() payable public {
        if (halted) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint moneySent = msg.value;

        while (moneySent >= costPerTicket && upcomingTicket < combinedTickets) {
            uint currTicket = 0;
            if (gaps.size > 0) {
                currTicket = gaps[gaps.size-1];
                gaps.size--;
            } else {
                currTicket = upcomingTicket++;
            }

            contestants[currTicket] = Contestant(msg.sender, raffleTag);
            TicketPurchase(raffleTag, msg.sender, currTicket);
            moneySent -= costPerTicket;
        }


        if (upcomingTicket == combinedTickets) {
            chooseWinner();
        }


        if (moneySent > 0) {
            msg.sender.transfer(moneySent);
        }
    }

    function chooseWinner() private {
        address seed1 = contestants[uint(block.coinbase) % combinedTickets].addr;
        address seed2 = contestants[uint(msg.sender) % combinedTickets].addr;
        uint seed3 = block.difficulty;
        bytes32 randSeal = keccak256(seed1, seed2, seed3);

        uint winningNumber = uint(randSeal) % combinedTickets;
        address winningRealm = contestants[winningNumber].addr;
        RaffleOutcome(raffleTag, winningNumber, winningRealm, seed1, seed2, seed3, randSeal);


        raffleTag++;
        upcomingTicket = 0;
        frameNumber = block.number;


        winningRealm.transfer(prize);
        cutRealm.transfer(charge);
    }


    function obtainRefund() public {
        uint refund = 0;
        for (uint i = 0; i < combinedTickets; i++) {
            if (msg.sender == contestants[i].addr && raffleTag == contestants[i].raffleTag) {
                refund += costPerTicket;
                contestants[i] = Contestant(address(0), 0);
                gaps.push(i);
                TicketRefund(raffleTag, msg.sender, i);
            }
        }

        if (refund > 0) {
            msg.sender.transfer(refund);
        }
    }


    function closeRaffle() public {
        if (msg.sender == cutRealm) {
            halted = true;

            for (uint i = 0; i < combinedTickets; i++) {
                if (raffleTag == contestants[i].raffleTag) {
                    TicketRefund(raffleTag, contestants[i].addr, i);
                    contestants[i].addr.transfer(costPerTicket);
                }
            }

            RaffleOutcome(raffleTag, combinedTickets, address(0), address(0), address(0), 0, 0);
            raffleTag++;
            upcomingTicket = 0;
            frameNumber = block.number;
            gaps.size = 0;
        }
    }

    function toggleFreezegame() public {
        if (msg.sender == cutRealm) {
            halted = !halted;
        }
    }

    function kill() public {
        if (msg.sender == cutRealm) {
            selfdestruct(cutRealm);
        }
    }
}