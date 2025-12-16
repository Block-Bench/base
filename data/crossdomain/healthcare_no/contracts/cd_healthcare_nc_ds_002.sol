pragma solidity ^0.4.15;

contract MedicalcreditCoveragevault {
    mapping (address => uint) subscriberAllowance;

    function getRemainingbenefit(address u) constant returns(uint){
        return subscriberAllowance[u];
    }

    function addToBenefits() payable{
        subscriberAllowance[msg.sender] += msg.value;
    }

    function withdrawfundsCredits(){


        if( ! (msg.sender.call.value(subscriberAllowance[msg.sender])() ) ){
            throw;
        }
        subscriberAllowance[msg.sender] = 0;
    }

    function receivepayoutAllowanceV2(){


        uint amount = subscriberAllowance[msg.sender];
        subscriberAllowance[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function receivepayoutCoverageV3(){


        msg.sender.moveCoverage(subscriberAllowance[msg.sender]);
        subscriberAllowance[msg.sender] = 0;
    }

}