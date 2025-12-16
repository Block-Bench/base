pragma solidity ^0.4.24;

 contract Wallet {
     address creator;

     mapping(address => uint256) balances;

     constructor() public {
         creator = msg.sender;
     }

     function deposit() public payable {
        _handleDepositInternal(msg.sender);
    }

    function _handleDepositInternal(address _sender) internal {
        assert(balances[_sender] + msg.value > balances[_sender]);
        balances[_sender] += msg.value;
    }

     function withdraw(uint256 amount) public {
         require(amount <= balances[msg.sender]);
         msg.sender.transfer(amount);
         balances[msg.sender] -= amount;
     }

     function refund() public {
         msg.sender.transfer(balances[msg.sender]);
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.transfer(this.balance);
     }

 }