pragma solidity ^0.4.24;

 contract Wallet {
     address _0xfdcf2b;

     mapping(address => uint256) _0x4884ec;

     constructor() public {
         _0xfdcf2b = msg.sender;
     }

     function _0x0cbbd9() public payable {
         assert(_0x4884ec[msg.sender] + msg.value > _0x4884ec[msg.sender]);
         _0x4884ec[msg.sender] += msg.value;
     }

     function _0x69c763(uint256 _0xeb144c) public {
         require(_0xeb144c >= _0x4884ec[msg.sender]);
         msg.sender.transfer(_0xeb144c);
         _0x4884ec[msg.sender] -= _0xeb144c;
     }


     function _0xae03f8(address _0xf8ac89) public {
         require(_0xfdcf2b == msg.sender);
         _0xf8ac89.transfer(this.balance);
     }

 }