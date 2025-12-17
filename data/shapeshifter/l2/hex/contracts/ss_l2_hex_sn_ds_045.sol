// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract TokenVault {
     mapping (address => uint) _0xea0025;

     function _0xc93cc8(address u) constant returns(uint){
         return _0xea0025[u];
     }

     function _0x6232a4() payable{
         _0xea0025[msg.sender] += msg.value;
     }

     function _0x82e755(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.value(_0xea0025[msg.sender])() ) ){
             throw;
         }
         _0xea0025[msg.sender] = 0;
     }
 }