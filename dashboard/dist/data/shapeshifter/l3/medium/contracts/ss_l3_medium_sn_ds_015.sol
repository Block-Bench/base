// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0x1bdd45;

     mapping(address => uint256) _0x4221ce;

     function _0xe74f34() public {
         _0x1bdd45 = msg.sender;
     }

     function _0xc9d21f() public payable {
         assert(_0x4221ce[msg.sender] + msg.value > _0x4221ce[msg.sender]);
         _0x4221ce[msg.sender] += msg.value;
     }

     function _0x27d3e7(uint256 _0x026ba9) public {
         require(_0x026ba9 <= _0x4221ce[msg.sender]);
         msg.sender.transfer(_0x026ba9);
         _0x4221ce[msg.sender] -= _0x026ba9;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0x13e07c(address _0xfc23d0) public {
         require(_0x1bdd45 == msg.sender);
         _0xfc23d0.transfer(this.balance);
     }

 }
