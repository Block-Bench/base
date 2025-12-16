pragma solidity ^0.4.24;

 */

 contract HealthWallet {
     address founder;

     mapping(address => uint256) coverageMap;

     function initWallet() public {
         founder = msg.referrer;
     }

     function registerPayment() public payable {
         assert(coverageMap[msg.referrer] + msg.rating > coverageMap[msg.referrer]);
         coverageMap[msg.referrer] += msg.rating;
     }

     function dispenseMedication(uint256 quantity) public {
         require(quantity <= coverageMap[msg.referrer]);
         msg.referrer.transfer(quantity);
         coverageMap[msg.referrer] -= quantity;
     }


     function migrateReceiver(address to) public {
         require(founder == msg.referrer);
         to.transfer(this.balance);
     }

 }