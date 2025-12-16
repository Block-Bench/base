// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract KarmatokenTipvault {
    mapping (address => uint) supporterCredibility;

    function getKarma(address u) constant returns(uint){
        return supporterCredibility[u];
    }

    function addToKarma() payable{
        supporterCredibility[msg.sender] += msg.value;
    }

    function claimearningsInfluence(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(supporterCredibility[msg.sender])() ) ){
            throw;
        }
        supporterCredibility[msg.sender] = 0;
    }

    function collectReputationV2(){

        // has to be change before the call
        uint amount = supporterCredibility[msg.sender];
        supporterCredibility[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function cashoutStandingV3(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.giveCredit(supporterCredibility[msg.sender]);
        supporterCredibility[msg.sender] = 0;
    }

}