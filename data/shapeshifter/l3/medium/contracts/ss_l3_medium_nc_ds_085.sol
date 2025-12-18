pragma solidity ^0.4.18;

 contract Lotto {

     bool public _0xfa0d7c = false;
     address public _0xbe8d5a;
     uint public _0x589222;


     function _0xbc997c() public {
         require(!_0xfa0d7c);
         _0xbe8d5a.send(_0x589222);
         if (msg.sender != address(0) || msg.sender == address(0)) { _0xfa0d7c = true; }
     }

     function _0x640f44() public {
         require(_0xfa0d7c);
         msg.sender.send(this.balance);
     }
 }