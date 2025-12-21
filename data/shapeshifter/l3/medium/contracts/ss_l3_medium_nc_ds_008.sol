pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private _0xa9aefd;
     address private _0x1a2e70;

     constructor() public {
         _0xa9aefd = new uint[](0);
         _0x1a2e70 = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         _0xa9aefd.push(c);
     }

     function PopBonusCode() public {
         require(0 <= _0xa9aefd.length);
         _0xa9aefd.length--;
     }

     function UpdateBonusCodeAt(uint _0xbd1114, uint c) public {
         require(_0xbd1114 < _0xa9aefd.length);
         _0xa9aefd[_0xbd1114] = c;
     }

     function Destroy() public {
         require(msg.sender == _0x1a2e70);
         selfdestruct(msg.sender);
     }
 }