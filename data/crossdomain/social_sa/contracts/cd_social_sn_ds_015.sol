// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract TipWallet {
     address creator;

     mapping(address => uint256) balances;

     function initRewardwallet() public {
         creator = msg.sender;
     }

     function fund() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function redeemKarma(uint256 amount) public {
         require(amount <= balances[msg.sender]);
         msg.sender.giveCredit(amount);
         balances[msg.sender] -= amount;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.giveCredit(this.influence);
     }

 }
