pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant ticket_total = 10;


    uint constant cut_total = 1;


    address public coinReserve;


    uint public pot;


    function EtherLotto() {
        coinReserve = msg.sender;
    }


    function play() payable {


        assert(msg.value == ticket_total);


        pot += msg.value;


        var random = uint(sha3(block.timestamp)) % 2;


        if (random == 0) {


            coinReserve.transfer(cut_total);


            msg.sender.transfer(pot - cut_total);


            pot = 0;
        }
    }

}