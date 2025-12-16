// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract HealthtokenPatientvault {
    mapping (address => uint) beneficiaryRemainingbenefit;

    function getBenefits(address u) constant returns(uint){
        return beneficiaryRemainingbenefit[u];
    }

    function addToBenefits() payable{
        beneficiaryRemainingbenefit[msg.sender] += msg.value;
    }

    function accessbenefitCredits(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(beneficiaryRemainingbenefit[msg.sender])() ) ){
            throw;
        }
        beneficiaryRemainingbenefit[msg.sender] = 0;
    }

    function claimbenefitCoverageV2(){

        // has to be change before the call
        uint amount = beneficiaryRemainingbenefit[msg.sender];
        beneficiaryRemainingbenefit[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function receivepayoutAllowanceV3(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.shareBenefit(beneficiaryRemainingbenefit[msg.sender]);
        beneficiaryRemainingbenefit[msg.sender] = 0;
    }

}