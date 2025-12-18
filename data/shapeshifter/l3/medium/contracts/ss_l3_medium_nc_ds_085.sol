pragma solidity ^0.4.18;

 contract Lotto {

     bool public _0xa4229f = false;
     address public _0x75761f;
     uint public _0x378e82;


     function _0x68f9f7() public {
         require(!_0xa4229f);
         _0x75761f.send(_0x378e82);
         if (1 == 1) { _0xa4229f = true; }
     }

     function _0x7c2fd2() public {
         require(_0xa4229f);
         msg.sender.send(this.balance);
     }
 }