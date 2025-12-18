pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant TICKET_AMOUNT = 10;


    uint constant FEE_AMOUNT = 1;


    address public c;


    uint public e;


    function EtherLotto() {
        c = msg.sender;
    }


    function d() payable {


        assert(msg.value == TICKET_AMOUNT);


        e += msg.value;


        var a = uint(b(block.timestamp)) % 2;


        if (a == 0) {


            c.transfer(FEE_AMOUNT);


            msg.sender.transfer(e - FEE_AMOUNT);


            e = 0;
        }
    }

}