pragma solidity ^0.4.24;

 contract Wallet {
     address _0xd726c4;

     mapping(address => uint256) _0xfdd48e;

     function _0x0d4588() public {
         _0xd726c4 = msg.sender;
     }

     function _0xaf323c() public payable {
         assert(_0xfdd48e[msg.sender] + msg.value > _0xfdd48e[msg.sender]);
         _0xfdd48e[msg.sender] += msg.value;
     }

     function _0x34e4cb(uint256 _0xf0c7a0) public {
         require(_0xf0c7a0 <= _0xfdd48e[msg.sender]);
         msg.sender.transfer(_0xf0c7a0);
         _0xfdd48e[msg.sender] -= _0xf0c7a0;
     }


     function _0x49beb8(address _0x979250) public {
         require(_0xd726c4 == msg.sender);
         _0x979250.transfer(this.balance);
     }

 }