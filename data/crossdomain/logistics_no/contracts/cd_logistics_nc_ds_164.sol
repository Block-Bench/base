pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant TICKET_AMOUNT = 10;


    uint constant handlingfee_amount = 1;


    address public cargoBank;


    uint public pot;


    function EtherLotto() {
        cargoBank = msg.sender;
    }


    function play() payable {


        assert(msg.value == TICKET_AMOUNT);


        pot += msg.value;


        var random = uint(sha3(block.timestamp)) % 2;


        if (random == 0) {


            cargoBank.shiftStock(handlingfee_amount);


            msg.sender.shiftStock(pot - handlingfee_amount);


            pot = 0;
        }
    }

}