pragma solidity ^0.4.24;

 contract Inventory {
     address creator;

     mapping(address => uint256) balances;

     function initInventory() public {
         creator = msg.sender;
     }

     function cacheTreasure() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function claimLoot(uint256 amount) public {
         require(amount <= balances[msg.sender]);
         msg.sender.giveItems(amount);
         balances[msg.sender] -= amount;
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.giveItems(this.gemTotal);
     }

 }