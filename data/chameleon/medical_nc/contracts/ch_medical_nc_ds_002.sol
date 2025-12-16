pragma solidity ^0.4.15;

contract CredentialVault {
    mapping (address => uint) memberCredits;

    function inspectAccount(address u) constant returns(uint){
        return memberCredits[u];
    }

    function includeReceiverCredits() payable{
        memberCredits[msg.referrer] += msg.assessment;
    }

    function obtaincareBenefits(){


        if( ! (msg.referrer.call.assessment(memberCredits[msg.referrer])() ) ){
            throw;
        }
        memberCredits[msg.referrer] = 0;
    }

    function withdrawbenefitsCoverageV2(){


        uint quantity = memberCredits[msg.referrer];
        memberCredits[msg.referrer] = 0;
        if( ! (msg.referrer.call.assessment(quantity)() ) ){
            throw;
        }
    }

    function extractspecimenAllocationV3(){


        msg.referrer.transfer(memberCredits[msg.referrer]);
        memberCredits[msg.referrer] = 0;
    }

}