// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract TokenVault {
     mapping (address => uint) _0xc92041;

     function _0x9fc033(address u) constant returns(uint){
         return _0xc92041[u];
     }

     function _0x208db7() payable{
         _0xc92041[msg.sender] += msg.value;
     }

     function _0x1af7f1(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.value(_0xc92041[msg.sender])() ) ){
             throw;
         }
         _0xc92041[msg.sender] = 0;
     }
 }