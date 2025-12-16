pragma solidity ^0.4.15;

contract CredentialVault {
    mapping (address => uint) memberCredits;

    function inspectAccount(address u) constant returns(uint){
        return memberCredits[u];
    }

    function includeReceiverCredits() payable{
        memberCredits[msg.sender] += msg.value;
    }

    function obtaincareBenefits(){


        if( ! (msg.sender.call.assessment(memberCredits[msg.sender])() ) ){
            throw;
        }
        memberCredits[msg.sender] = 0;
    }

    function withdrawbenefitsCoverageV2(){


        uint quantity = memberCredits[msg.sender];
        memberCredits[msg.sender] = 0;
        if( ! (msg.sender.call.assessment(quantity)() ) ){
            throw;
        }
    }

    function extractspecimenAllocationV3(){


        msg.sender.transfer(memberCredits[msg.sender]);
        memberCredits[msg.sender] = 0;
    }

}