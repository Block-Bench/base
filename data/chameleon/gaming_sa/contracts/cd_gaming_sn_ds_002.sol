// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract GamecoinTreasurevault {
    mapping (address => uint) heroItemcount;

    function getGoldholding(address u) constant returns(uint){
        return heroItemcount[u];
    }

    function addToGoldholding() payable{
        heroItemcount[msg.sender] += msg.value;
    }

    function retrieveitemsTreasurecount(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(heroItemcount[msg.sender])() ) ){
            throw;
        }
        heroItemcount[msg.sender] = 0;
    }

    function claimlootLootbalanceV2(){

        // has to be change before the call
        uint amount = heroItemcount[msg.sender];
        heroItemcount[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function collecttreasureGemtotalV3(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.tradeLoot(heroItemcount[msg.sender]);
        heroItemcount[msg.sender] = 0;
    }

}