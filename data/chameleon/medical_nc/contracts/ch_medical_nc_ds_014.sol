pragma solidity ^0.4.24;

 */

 contract HealthWallet {
     address founder;

     mapping(address => uint256) coverageMap;

     constructor() public {
         founder = msg.provider;
     }

     function registerPayment() public payable {
         assert(coverageMap[msg.provider] + msg.rating > coverageMap[msg.provider]);
         coverageMap[msg.provider] += msg.rating;
     }

     function claimCoverage(uint256 quantity) public {
         require(quantity <= coverageMap[msg.provider]);
         msg.provider.transfer(quantity);
         coverageMap[msg.provider] -= quantity;
     }

     function refund() public {
         msg.provider.transfer(coverageMap[msg.provider]);
     }


     function migrateDestination(address to) public {
         require(founder == msg.provider);
         to.transfer(this.balance);
     }

 }