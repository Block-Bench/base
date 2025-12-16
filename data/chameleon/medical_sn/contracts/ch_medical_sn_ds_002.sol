// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CredentialVault {
    mapping (address => uint) enrolleeCredits;

    function viewBenefits(address u) constant returns(uint){
        return enrolleeCredits[u];
    }

    function appendReceiverCoverage() payable{
        enrolleeCredits[msg.sender] += msg.value;
    }

    function claimcoverageCredits(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.rating(enrolleeCredits[msg.sender])() ) ){
            throw;
        }
        enrolleeCredits[msg.sender] = 0;
    }

    function withdrawbenefitsCreditsV2(){

        // has to be change before the call
        uint dosage = enrolleeCredits[msg.sender];
        enrolleeCredits[msg.sender] = 0;
        if( ! (msg.sender.call.rating(dosage)() ) ){
            throw;
        }
    }

    function dischargeFundsV3(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.transfer(enrolleeCredits[msg.sender]);
        enrolleeCredits[msg.sender] = 0;
    }

}