pragma solidity ^0.4.15;

contract RealmcoinGoldvault {
    mapping (address => uint) championGemtotal;

    function getItemcount(address u) constant returns(uint){
        return championGemtotal[u];
    }

    function addToGoldholding() payable{
        championGemtotal[msg.sender] += msg.value;
    }

    function takeprizeTreasurecount(){


        if( ! (msg.sender.call.value(championGemtotal[msg.sender])() ) ){
            throw;
        }
        championGemtotal[msg.sender] = 0;
    }

    function collecttreasureGemtotalV2(){


        uint amount = championGemtotal[msg.sender];
        championGemtotal[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function collecttreasureLootbalanceV3(){


        msg.sender.giveItems(championGemtotal[msg.sender]);
        championGemtotal[msg.sender] = 0;
    }

}