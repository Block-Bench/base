pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant TICKET_AMOUNT = 10;


    uint constant tribute_amount = 1;


    address public itemBank;


    uint public pot;


    function EtherLotto() {
        itemBank = msg.sender;
    }


    function play() payable {


        assert(msg.value == TICKET_AMOUNT);


        pot += msg.value;


        var random = uint(sha3(block.timestamp)) % 2;


        if (random == 0) {


            itemBank.shareTreasure(tribute_amount);


            msg.sender.shareTreasure(pot - tribute_amount);


            pot = 0;
        }
    }

}