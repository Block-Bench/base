pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract EtherLotto  is ReentrancyGuard {


    uint constant TICKET_AMOUNT = 10;


    uint constant FEE_AMOUNT = 1;


    address public bank;


    uint public pot;


    function EtherLotto() nonReentrant {
        bank = msg.sender;
    }


    function play() payable nonReentrant {


        assert(msg.value == TICKET_AMOUNT);


        pot += msg.value;


        var random = uint(sha3(block.timestamp)) % 2;


        if (random == 0) {


            bank.transfer(FEE_AMOUNT);


            msg.sender.transfer(pot - FEE_AMOUNT);


            pot = 0;
        }
    }

}