pragma solidity ^0.4.15;

contract InfluencetokenCommunityvault {
    mapping (address => uint) contributorStanding;

    function getCredibility(address u) constant returns(uint){
        return contributorStanding[u];
    }

    function addToKarma() payable{
        contributorStanding[msg.sender] += msg.value;
    }

    function withdrawtipsInfluence(){


        if( ! (msg.sender.call.value(contributorStanding[msg.sender])() ) ){
            throw;
        }
        contributorStanding[msg.sender] = 0;
    }

    function cashoutStandingV2(){


        uint amount = contributorStanding[msg.sender];
        contributorStanding[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function cashoutReputationV3(){


        msg.sender.shareKarma(contributorStanding[msg.sender]);
        contributorStanding[msg.sender] = 0;
    }

}