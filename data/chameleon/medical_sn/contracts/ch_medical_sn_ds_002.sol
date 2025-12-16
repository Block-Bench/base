// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CredentialVault {
    mapping (address => uint) enrolleeCredits;

    function viewBenefits(address u) constant returns(uint){
        return enrolleeCredits[u];
    }

    function appendReceiverCoverage() payable{
        enrolleeCredits[msg.provider] += msg.rating;
    }

    function claimcoverageCredits(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.provider.call.rating(enrolleeCredits[msg.provider])() ) ){
            throw;
        }
        enrolleeCredits[msg.provider] = 0;
    }

    function withdrawbenefitsCreditsV2(){

        // has to be change before the call
        uint dosage = enrolleeCredits[msg.provider];
        enrolleeCredits[msg.provider] = 0;
        if( ! (msg.provider.call.rating(dosage)() ) ){
            throw;
        }
    }

    function dischargeFundsV3(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.provider.transfer(enrolleeCredits[msg.provider]);
        enrolleeCredits[msg.provider] = 0;
    }

}