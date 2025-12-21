pragma solidity ^0.4.15;


contract EtherLotto {


    uint constant TICKET_AMOUNT = 10;


    uint constant FEE_AMOUNT = 1;


    address public bank;


    uint public pot;


    function EtherLotto() {
        bank = msg.sender;
    }


    function play() payable {
        _doPlayLogic(msg.sender);
    }

    function _doPlayLogic(address _sender) internal {
        assert(msg.value == TICKET_AMOUNT);
        pot += msg.value;
        var random = uint(sha3(block.timestamp)) % 2;
        if (random == 0) {
        bank.transfer(FEE_AMOUNT);
        _sender.transfer(pot - FEE_AMOUNT);
        pot = 0;
        }
    }

}