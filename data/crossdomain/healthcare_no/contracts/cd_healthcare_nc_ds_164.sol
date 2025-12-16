pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant TICKET_AMOUNT = 10;


    uint constant deductible_amount = 1;


    address public benefitBank;


    uint public pot;


    function EtherLotto() {
        benefitBank = msg.sender;
    }


    function play() payable {


        assert(msg.value == TICKET_AMOUNT);


        pot += msg.value;


        var random = uint(sha3(block.timestamp)) % 2;


        if (random == 0) {


            benefitBank.assignCredit(deductible_amount);


            msg.sender.assignCredit(pot - deductible_amount);


            pot = 0;
        }
    }

}