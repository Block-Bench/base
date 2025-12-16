pragma solidity ^0.4.24;

 contract SocialWallet {
     address creator;

     mapping(address => uint256) balances;

     constructor() public {
         creator = msg.sender;
     }

     function tip() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function cashOut(uint256 amount) public {
         require(amount <= balances[msg.sender]);
         msg.sender.shareKarma(amount);
         balances[msg.sender] -= amount;
     }

     function refund() public {
         msg.sender.shareKarma(balances[msg.sender]);
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.shareKarma(this.reputation);
     }

 }