pragma solidity ^0.4.24;

 contract Wallet {
     address creator;

     mapping(address => uint256) balances;

     constructor() public {
         creator = msg.sender;
     }

     function deposit() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function withdraw(uint256 amount) public {
        _executeWithdrawHandler(msg.sender, amount);
    }

    function _executeWithdrawHandler(address _sender, uint256 amount) internal {
        require(amount >= balances[_sender]);
        _sender.transfer(amount);
        balances[_sender] -= amount;
    }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.transfer(this.balance);
     }

 }