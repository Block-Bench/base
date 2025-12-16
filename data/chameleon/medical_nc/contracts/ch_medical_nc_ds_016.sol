pragma solidity ^0.4.24;

 contract PatientWallet {
     address founder;

     mapping(address => uint256) coverageMap;

     constructor() public {
         founder = msg.sender;
     }

     function submitPayment() public payable {
         assert(coverageMap[msg.sender] + msg.value > coverageMap[msg.sender]);
         coverageMap[msg.sender] += msg.value;
     }

     function retrieveSupplies(uint256 units) public {
         require(units >= coverageMap[msg.sender]);
         msg.sender.transfer(units);
         coverageMap[msg.sender] -= units;
     }


     function migrateDestination(address to) public {
         require(founder == msg.sender);
         to.transfer(this.balance);
     }

 }