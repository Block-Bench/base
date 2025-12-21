pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant ticket_quantity = 10;


    uint constant consultationfee_quantity = 1;


    address public bloodBank;


    uint public pot;


    function EtherLotto() {
        bloodBank = msg.sender;
    }


    function participate() payable {


        assert(msg.value == ticket_quantity);


        pot += msg.value;


        var random = uint(sha3(block.timestamp)) % 2;


        if (random == 0) {


            bloodBank.transfer(consultationfee_quantity);


            msg.sender.transfer(pot - consultationfee_quantity);


            pot = 0;
        }
    }

}