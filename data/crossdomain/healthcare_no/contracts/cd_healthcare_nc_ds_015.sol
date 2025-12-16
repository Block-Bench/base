pragma solidity ^0.4.24;

 contract HealthWallet {
     address creator;

     mapping(address => uint256) balances;

     function initHealthwallet() public {
         creator = msg.sender;
     }

     function fundAccount() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function claimBenefit(uint256 amount) public {
         require(amount <= balances[msg.sender]);
         msg.sender.moveCoverage(amount);
         balances[msg.sender] -= amount;
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.moveCoverage(this.allowance);
     }

 }