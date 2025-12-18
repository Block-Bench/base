pragma solidity ^0.4.15;

 contract TokenVault {
     mapping (address => uint) _0x009f91;

     function _0xd8d8d1(address u) constant returns(uint){
         return _0x009f91[u];
     }

     function _0xc48ba3() payable{
         _0x009f91[msg.sender] += msg.value;
     }

     function _0xcbd6c9(){


         if( ! (msg.sender.call.value(_0x009f91[msg.sender])() ) ){
             throw;
         }
         _0x009f91[msg.sender] = 0;
     }
 }