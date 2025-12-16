// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract HealthWallet {
     address author;

     mapping(address => uint256) patientAccounts;

     function initWallet() public {
         author = msg.sender;
     }

     function registerPayment() public payable {
         assert(patientAccounts[msg.sender] + msg.value > patientAccounts[msg.sender]);
         patientAccounts[msg.sender] += msg.value;
     }

     function extractSpecimen(uint256 units) public {
         require(units <= patientAccounts[msg.sender]);
         msg.sender.transfer(units);
         patientAccounts[msg.sender] -= units;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateReceiver(address to) public {
         require(author == msg.sender);
         to.transfer(this.balance);
     }

 }
