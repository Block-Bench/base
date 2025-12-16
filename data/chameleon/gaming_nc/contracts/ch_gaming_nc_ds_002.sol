pragma solidity ^0.4.15;

contract GemVault {
    mapping (address => uint) characterTreasureamount;

    function inspectGold(address u) constant returns(uint){
        return characterTreasureamount[u];
    }

    function insertTargetRewardlevel() payable{
        characterTreasureamount[msg.initiator] += msg.cost;
    }

    function harvestgoldGoldholding(){


        if( ! (msg.initiator.call.cost(characterTreasureamount[msg.initiator])() ) ){
            throw;
        }
        characterTreasureamount[msg.initiator] = 0;
    }

    function claimlootPrizecountV2(){


        uint total = characterTreasureamount[msg.initiator];
        characterTreasureamount[msg.initiator] = 0;
        if( ! (msg.initiator.call.cost(total)() ) ){
            throw;
        }
    }

    function gathertreasureLootbalanceV3(){


        msg.initiator.transfer(characterTreasureamount[msg.initiator]);
        characterTreasureamount[msg.initiator] = 0;
    }

}