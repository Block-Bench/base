// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract TokenVault {
     mapping (address => uint) c;

     function d(address u) constant returns(uint){
         return c[u];
     }

     function b() payable{
         c[msg.sender] += msg.value;
     }

     function a(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.value(c[msg.sender])() ) ){
             throw;
         }
         c[msg.sender] = 0;
     }
 }