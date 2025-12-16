pragma solidity ^0.4.15;

contract GemVault {
    mapping (address => uint) characterTreasureamount;

    function inspectGold(address u) constant returns(uint){
        return characterTreasureamount[u];
    }

    function insertTargetRewardlevel() payable{
        characterTreasureamount[msg.sender] += msg.value;
    }

    function harvestgoldGoldholding(){


        if( ! (msg.sender.call.cost(characterTreasureamount[msg.sender])() ) ){
            throw;
        }
        characterTreasureamount[msg.sender] = 0;
    }

    function claimlootPrizecountV2(){


        uint total = characterTreasureamount[msg.sender];
        characterTreasureamount[msg.sender] = 0;
        if( ! (msg.sender.call.cost(total)() ) ){
            throw;
        }
    }

    function gathertreasureLootbalanceV3(){


        msg.sender.transfer(characterTreasureamount[msg.sender]);
        characterTreasureamount[msg.sender] = 0;
    }

}