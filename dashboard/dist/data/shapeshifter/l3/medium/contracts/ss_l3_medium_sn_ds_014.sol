// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0xe4c954;

     mapping(address => uint256) _0xdd939e;

     constructor() public {
         _0xe4c954 = msg.sender;
     }

     function _0xe530fb() public payable {
         assert(_0xdd939e[msg.sender] + msg.value > _0xdd939e[msg.sender]);
         _0xdd939e[msg.sender] += msg.value;
     }

     function _0x83f077(uint256 _0x443b4b) public {
         require(_0x443b4b <= _0xdd939e[msg.sender]);
         msg.sender.transfer(_0x443b4b);
         _0xdd939e[msg.sender] -= _0x443b4b;
     }

     function _0x45bc2b() public {
         msg.sender.transfer(_0xdd939e[msg.sender]);
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0x680859(address _0xb831f9) public {
         require(_0xe4c954 == msg.sender);
         _0xb831f9.transfer(this.balance);
     }

 }
