pragma solidity ^0.4.15;

 contract TokenVault {
     mapping (address => uint) _0x1b5bde;

     function _0x9c42a0(address u) constant returns(uint){
         return _0x1b5bde[u];
     }

     function _0x777f8c() payable{
         _0x1b5bde[msg.sender] += msg.value;
     }

     function _0x3e80f5(){


         if( ! (msg.sender.call.value(_0x1b5bde[msg.sender])() ) ){
             throw;
         }
         _0x1b5bde[msg.sender] = 0;
     }
 }