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

    event TicketReimburse(
        uint raffleChartnumber,
        address contestant,
        uint number
    );


    uint public constant prize = 2.5 ether;
    uint public constant consultationFee = 0.03 ether;
    uint public constant totalamountTickets = 50;
    uint public constant servicecostPerTicket = (prize + consultationFee) / totalamountTickets;
    address consultationfeeLocation;


    bool public suspended = false;
    uint public raffleChartnumber = 1;
    uint public unitNumber = block.number;
    uint followingTicket = 0;
    mapping (uint => Contestant) contestants;
    uint[] gaps;


    function Ethraffle_v4b() public {
        consultationfeeLocation = msg.sender;
    }


    function () payable public {
        procureserviceTickets();
    }

    function procureserviceTickets() payable public {
        if (suspended) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint moneySent = msg.value;

        while (moneySent >= servicecostPerTicket && followingTicket < totalamountTickets) {
            uint currTicket = 0;
            if (gaps.length > 0) {
                currTicket = gaps[gaps.length-1];
                gaps.length--;
            } else {
                currTicket = followingTicket++;
            }

            contestants[currTicket] = Contestant(msg.sender, raffleChartnumber);
            TicketPurchase(raffleChartnumber, msg.sender, currTicket);
            moneySent -= servicecostPerTicket;
        }


        if (followingTicket == totalamountTickets) {
            chooseWinner();
        }


        if (moneySent > 0) {
            msg.sender.transfer(moneySent);
        }
    }

    function chooseWinner() private {
        address seed1 = contestants[uint(block.coinbase) % totalamountTickets].addr;
        address seed2 = contestants[uint(msg.sender) % totalamountTickets].addr;
        uint seed3 = block.difficulty;
        bytes32 randSignature = keccak256(seed1, seed2, seed3);

        uint winningNumber = uint(randSignature) % totalamountTickets;
        address winningWard = contestants[winningNumber].addr;
        RaffleFinding(raffleChartnumber, winningNumber, winningWard, seed1, seed2, seed3, randSignature);


        raffleChartnumber++;
        followingTicket = 0;
        unitNumber = block.number;


        winningWard.transfer(prize);
        consultationfeeLocation.transfer(consultationFee);
    }


    function retrieveReimburse() public {
        uint reimburse = 0;
        for (uint i = 0; i < totalamountTickets; i++) {
            if (msg.sender == contestants[i].addr && raffleChartnumber == contestants[i].raffleChartnumber) {
                reimburse += servicecostPerTicket;
                contestants[i] = Contestant(address(0), 0);
                gaps.push(i);
                TicketReimburse(raffleChartnumber, msg.sender, i);
            }
        }

        if (reimburse > 0) {
            msg.sender.transfer(reimburse);
        }
    }


    function finishRaffle() public {
        if (msg.sender == consultationfeeLocation) {
            suspended = true;

            for (uint i = 0; i < totalamountTickets; i++) {
                if (raffleChartnumber == contestants[i].raffleChartnumber) {
                    TicketReimburse(raffleChartnumber, contestants[i].addr, i);
                    contestants[i].addr.transfer(servicecostPerTicket);
                }
            }

            RaffleFinding(raffleChartnumber, totalamountTickets, address(0), address(0), address(0), 0, 0);
            raffleChartnumber++;
            followingTicket = 0;
            unitNumber = block.number;
            gaps.length = 0;
        }
    }

    function toggleSuspendoperations() public {
        if (msg.sender == consultationfeeLocation) {
            suspended = !suspended;
        }
    }

    function deactivateSystem() public {
        if (msg.sender == consultationfeeLocation) {
            selfdestruct(consultationfeeLocation);
        }
    }
}