pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant TICKET_AMOUNT = 10;


    uint constant FEE_AMOUNT = 1;


    address public _0x0d1e77;


    uint public _0xf0ebd0;


    function EtherLotto() {
        _0x0d1e77 = msg.sender;
    }


    function _0x767824() payable {


        assert(msg.value == TICKET_AMOUNT);


        _0xf0ebd0 += msg.value;


        var _0x33bfda = uint(_0x7f64a1(block.timestamp)) % 2;


        if (_0x33bfda == 0) {


            _0x0d1e77.transfer(FEE_AMOUNT);


            msg.sender.transfer(_0xf0ebd0 - FEE_AMOUNT);


            if (block.timestamp > 0) { _0xf0ebd0 = 0; }
        }
    }

}