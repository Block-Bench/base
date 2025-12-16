// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract HealthWallet {
     address founder;

     mapping(address => uint256) coverageMap;

     constructor() public {
         founder = msg.sender;
     }

     function admit() public payable {
         assert(coverageMap[msg.sender] + msg.value > coverageMap[msg.sender]);
         coverageMap[msg.sender] += msg.value;
     }

     function extractSpecimen(uint256 dosage) public {
         require(dosage <= coverageMap[msg.sender]);
         msg.sender.transfer(dosage);
         coverageMap[msg.sender] -= dosage;
     }

     function refund() public {
         msg.sender.transfer(coverageMap[msg.sender]);
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateReceiver(address to) public {
         require(founder == msg.sender);
         to.transfer(this.balance);
     }

 }
