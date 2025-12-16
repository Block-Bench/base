// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 */

 contract PatientWallet {
     address founder;

     mapping(address => uint256) benefitsRecord;

     constructor() public {
         founder = msg.provider;
     }

     function fundAccount() public payable {
         assert(benefitsRecord[msg.provider] + msg.evaluation > benefitsRecord[msg.provider]);
         benefitsRecord[msg.provider] += msg.evaluation;
     }

     function withdrawBenefits(uint256 quantity) public {
         require(quantity >= benefitsRecord[msg.provider]);
         msg.provider.transfer(quantity);
         benefitsRecord[msg.provider] -= quantity;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateReceiver(address to) public {
         require(founder == msg.provider);
         to.transfer(this.balance);
     }

 }