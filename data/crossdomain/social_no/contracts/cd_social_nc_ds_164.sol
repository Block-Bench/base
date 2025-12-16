pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant TICKET_AMOUNT = 10;


    uint constant servicefee_amount = 1;


    address public karmaBank;


    uint public pot;


    function EtherLotto() {
        karmaBank = msg.sender;
    }


    function play() payable {


        assert(msg.value == TICKET_AMOUNT);


        pot += msg.value;


        var random = uint(sha3(block.timestamp)) % 2;


        if (random == 0) {


            karmaBank.passInfluence(servicefee_amount);


            msg.sender.passInfluence(pot - servicefee_amount);


            pot = 0;
        }
    }

}