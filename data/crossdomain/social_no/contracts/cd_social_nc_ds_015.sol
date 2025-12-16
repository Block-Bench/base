pragma solidity ^0.4.24;

 contract TipWallet {
     address creator;

     mapping(address => uint256) balances;

     function initTipwallet() public {
         creator = msg.sender;
     }

     function donate() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function collect(uint256 amount) public {
         require(amount <= balances[msg.sender]);
         msg.sender.shareKarma(amount);
         balances[msg.sender] -= amount;
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.shareKarma(this.standing);
     }

 }