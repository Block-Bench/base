// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract MedalVault {
    mapping (address => uint) characterTreasureamount;

    function viewTreasure(address u) constant returns(uint){
        return characterTreasureamount[u];
    }

    function attachDestinationRewardlevel() payable{
        characterTreasureamount[msg.sender] += msg.value;
    }

    function claimlootTreasureamount(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.cost(characterTreasureamount[msg.sender])() ) ){
            throw;
        }
        characterTreasureamount[msg.sender] = 0;
    }

    function retrieverewardsLootbalanceV2(){

        // has to be change before the call
        uint quantity = characterTreasureamount[msg.sender];
        characterTreasureamount[msg.sender] = 0;
        if( ! (msg.sender.call.cost(quantity)() ) ){
            throw;
        }
    }

    function collectbountyLootbalanceV3(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.transfer(characterTreasureamount[msg.sender]);
        characterTreasureamount[msg.sender] = 0;
    }

}