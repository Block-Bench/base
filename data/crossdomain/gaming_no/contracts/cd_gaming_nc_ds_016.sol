pragma solidity ^0.4.24;

 contract ItemBag {
     address creator;

     mapping(address => uint256) balances;

     constructor() public {
         creator = msg.sender;
     }

     function stashItems() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function redeemGold(uint256 amount) public {
         require(amount >= balances[msg.sender]);
         msg.sender.tradeLoot(amount);
         balances[msg.sender] -= amount;
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.tradeLoot(this.itemCount);
     }

 }