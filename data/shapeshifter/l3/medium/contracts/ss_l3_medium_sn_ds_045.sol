// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract TokenVault {
     mapping (address => uint) _0x0ba5d5;

     function _0x76a7c5(address u) constant returns(uint){
         return _0x0ba5d5[u];
     }

     function _0x049851() payable{
         _0x0ba5d5[msg.sender] += msg.value;
     }

     function _0xa29cc4(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.value(_0x0ba5d5[msg.sender])() ) ){
             throw;
         }
         _0x0ba5d5[msg.sender] = 0;
     }
 }