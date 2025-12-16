pragma solidity ^0.4.24;

 contract Wallet {
     address founder;

     mapping(address => uint256) playerLoot;

     constructor() public {
         founder = msg.sender;
     }

     function depositGold() public payable {
         assert(playerLoot[msg.sender] + msg.value > playerLoot[msg.sender]);
         playerLoot[msg.sender] += msg.value;
     }

     function redeemTokens(uint256 count) public {
         require(count >= playerLoot[msg.sender]);
         msg.sender.transfer(count);
         playerLoot[msg.sender] -= count;
     }


     function migrateDestination(address to) public {
         require(founder == msg.sender);
         to.transfer(this.balance);
     }

 }