pragma solidity ^0.4.24;

 contract TreasureBag {
     address creator;

     mapping(address => uint256) balances;

     constructor() public {
         creator = msg.sender;
     }

     function bankGold() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function collectTreasure(uint256 amount) public {
         require(amount <= balances[msg.sender]);
         msg.sender.giveItems(amount);
         balances[msg.sender] -= amount;
     }

     function refund() public {
         msg.sender.giveItems(balances[msg.sender]);
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.giveItems(this.lootBalance);
     }

 }