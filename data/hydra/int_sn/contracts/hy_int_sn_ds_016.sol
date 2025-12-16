// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address creator;

     mapping(address => uint256) balances;

     constructor() public {
         creator = msg.sender;
     }

     function deposit() public payable {
        _DepositLogic(msg.sender);
    }

    function _DepositLogic(address _sender) internal {
        assert(balances[_sender] + msg.value > balances[_sender]);
        balances[_sender] += msg.value;
    }

     function withdraw(uint256 amount) public {
         require(amount >= balances[msg.sender]);
         msg.sender.transfer(amount);
         balances[msg.sender] -= amount;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.transfer(this.balance);
     }

 }
