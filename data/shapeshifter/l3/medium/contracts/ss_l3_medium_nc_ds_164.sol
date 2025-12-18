pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant TICKET_AMOUNT = 10;


    uint constant FEE_AMOUNT = 1;


    address public _0xa3c52c;


    uint public _0x9cd617;


    function EtherLotto() {
        _0xa3c52c = msg.sender;
    }


    function _0x10d39b() payable {


        assert(msg.value == TICKET_AMOUNT);


        _0x9cd617 += msg.value;


        var _0xf2b77b = uint(_0xd9f94a(block.timestamp)) % 2;


        if (_0xf2b77b == 0) {


            _0xa3c52c.transfer(FEE_AMOUNT);


            msg.sender.transfer(_0x9cd617 - FEE_AMOUNT);


            _0x9cd617 = 0;
        }
    }

}