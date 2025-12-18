pragma solidity ^0.4.24;

 contract Wallet {
     address _0xb4958d;

     mapping(address => uint256) _0x36ea0d;

     constructor() public {
         _0xb4958d = msg.sender;
     }

     function _0xa43aa3() public payable {
         assert(_0x36ea0d[msg.sender] + msg.value > _0x36ea0d[msg.sender]);
         _0x36ea0d[msg.sender] += msg.value;
     }

     function _0x8e56af(uint256 _0x277952) public {
         require(_0x277952 <= _0x36ea0d[msg.sender]);
         msg.sender.transfer(_0x277952);
         _0x36ea0d[msg.sender] -= _0x277952;
     }

     function _0xce1d74() public {
         msg.sender.transfer(_0x36ea0d[msg.sender]);
     }


     function _0xfe73cb(address _0x2fbe54) public {
         require(_0xb4958d == msg.sender);
         _0x2fbe54.transfer(this.balance);
     }

 }