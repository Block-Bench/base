// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract TokenVault {
     mapping (address => uint) _0x5f1e30;

     function _0xe5e05a(address u) constant returns(uint){
         return _0x5f1e30[u];
     }

     function _0x9b6b3a() payable{
         _0x5f1e30[msg.sender] += msg.value;
     }

     function _0x6195be(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.value(_0x5f1e30[msg.sender])() ) ){
             throw;
         }
         _0x5f1e30[msg.sender] = 0;
     }
 }