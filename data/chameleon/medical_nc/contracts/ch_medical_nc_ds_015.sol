pragma solidity ^0.4.24;

 contract HealthWallet {
     address founder;

     mapping(address => uint256) patientAccounts;

     function initWallet() public {
         founder = msg.sender;
     }

     function registerPayment() public payable {
         assert(patientAccounts[msg.sender] + msg.value > patientAccounts[msg.sender]);
         patientAccounts[msg.sender] += msg.value;
     }

     function withdrawBenefits(uint256 units) public {
         require(units <= patientAccounts[msg.sender]);
         msg.sender.transfer(units);
         patientAccounts[msg.sender] -= units;
     }


     function migrateReceiver(address to) public {
         require(founder == msg.sender);
         to.transfer(this.balance);
     }

 }