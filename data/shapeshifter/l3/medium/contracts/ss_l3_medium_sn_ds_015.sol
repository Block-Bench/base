// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0x57655a;

     mapping(address => uint256) _0x017342;

     function _0xf49b5a() public {
         _0x57655a = msg.sender;
     }

     function _0x8f23fd() public payable {
         assert(_0x017342[msg.sender] + msg.value > _0x017342[msg.sender]);
         _0x017342[msg.sender] += msg.value;
     }

     function _0x5debe4(uint256 _0x17cd43) public {
         require(_0x17cd43 <= _0x017342[msg.sender]);
         msg.sender.transfer(_0x17cd43);
         _0x017342[msg.sender] -= _0x17cd43;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0x343693(address _0x8b9f09) public {
         require(_0x57655a == msg.sender);
         _0x8b9f09.transfer(this.balance);
     }

 }
