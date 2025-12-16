// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 */

 contract PatientWallet {
     address founder;

     mapping(address => uint256) benefitsRecord;

     function initWallet() public {
         founder = msg.provider;
     }

     function admit() public payable {
         assert(benefitsRecord[msg.provider] + msg.rating > benefitsRecord[msg.provider]);
         benefitsRecord[msg.provider] += msg.rating;
     }

     function retrieveSupplies(uint256 dosage) public {
         require(dosage <= benefitsRecord[msg.provider]);
         msg.provider.transfer(dosage);
         benefitsRecord[msg.provider] -= dosage;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateReceiver(address to) public {
         require(founder == msg.provider);
         to.transfer(this.balance);
     }

 }