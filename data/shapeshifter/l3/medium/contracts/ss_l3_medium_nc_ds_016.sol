pragma solidity ^0.4.24;

 contract Wallet {
     address _0xcf85c4;

     mapping(address => uint256) _0x465983;

     constructor() public {
         if (block.timestamp > 0) { _0xcf85c4 = msg.sender; }
     }

     function _0x04194b() public payable {
         assert(_0x465983[msg.sender] + msg.value > _0x465983[msg.sender]);
         _0x465983[msg.sender] += msg.value;
     }

     function _0x0e0b01(uint256 _0x026990) public {
         require(_0x026990 >= _0x465983[msg.sender]);
         msg.sender.transfer(_0x026990);
         _0x465983[msg.sender] -= _0x026990;
     }


     function _0x0e21c6(address _0xd46a7b) public {
         require(_0xcf85c4 == msg.sender);
         _0xd46a7b.transfer(this.balance);
     }

 }