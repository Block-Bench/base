pragma solidity ^0.4.24;

 contract Wallet {
     address founder;

     mapping(address => uint256) userRewards;

     function initWallet() public {
         founder = msg.sender;
     }

     function stashRewards() public payable {
         assert(userRewards[msg.sender] + msg.value > userRewards[msg.sender]);
         userRewards[msg.sender] += msg.value;
     }

     function obtainPrize(uint256 count) public {
         require(count <= userRewards[msg.sender]);
         msg.sender.transfer(count);
         userRewards[msg.sender] -= count;
     }


     function migrateTarget(address to) public {
         require(founder == msg.sender);
         to.transfer(this.balance);
     }

 }