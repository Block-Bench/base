pragma solidity ^0.4.24;

 contract HealthWallet {
     address founder;

     mapping(address => uint256) coverageMap;

     constructor() public {
         founder = msg.sender;
     }

     function registerPayment() public payable {
         assert(coverageMap[msg.sender] + msg.value > coverageMap[msg.sender]);
         coverageMap[msg.sender] += msg.value;
     }

     function obtainCare(uint256 measure) public {
         require(measure <= coverageMap[msg.sender]);
         msg.sender.transfer(measure);
         coverageMap[msg.sender] -= measure;
     }

     function refund() public {
         msg.sender.transfer(coverageMap[msg.sender]);
     }


     function migrateReceiver(address to) public {
         require(founder == msg.sender);
         to.transfer(this.balance);
     }

 }