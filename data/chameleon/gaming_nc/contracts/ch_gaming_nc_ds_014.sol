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

     function gatherTreasure(uint256 total) public {
         require(total <= playerLoot[msg.sender]);
         msg.sender.transfer(total);
         playerLoot[msg.sender] -= total;
     }

     function refund() public {
         msg.sender.transfer(playerLoot[msg.sender]);
     }


     function migrateTarget(address to) public {
         require(founder == msg.sender);
         to.transfer(this.balance);
     }

 }