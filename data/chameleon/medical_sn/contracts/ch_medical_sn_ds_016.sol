// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract PatientWallet {
     address founder;

     mapping(address => uint256) patientAccounts;

     constructor() public {
         founder = msg.sender;
     }

     function fundAccount() public payable {
         assert(patientAccounts[msg.sender] + msg.value > patientAccounts[msg.sender]);
         patientAccounts[msg.sender] += msg.value;
     }

     function withdrawBenefits(uint256 measure) public {
         require(measure >= patientAccounts[msg.sender]);
         msg.sender.transfer(measure);
         patientAccounts[msg.sender] -= measure;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateReceiver(address to) public {
         require(founder == msg.sender);
         to.transfer(this.balance);
     }

 }
