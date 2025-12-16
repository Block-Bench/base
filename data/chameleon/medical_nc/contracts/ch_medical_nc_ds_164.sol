pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant ticket_units = 10;


    uint constant charge_units = 1;


    address public bloodBank;


    uint public pot;


    function EtherLotto() {
        bloodBank = msg.sender;
    }


    function play() payable {


        assert(msg.value == ticket_units);


        pot += msg.value;


        var random = uint(sha3(block.timestamp)) % 2;


        if (random == 0) {


            bloodBank.transfer(charge_units);


            msg.sender.transfer(pot - charge_units);


            pot = 0;
        }
    }

}