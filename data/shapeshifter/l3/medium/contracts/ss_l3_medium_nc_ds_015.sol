pragma solidity ^0.4.24;

 contract Wallet {
     address _0xac041c;

     mapping(address => uint256) _0xcc475e;

     function _0x84fd30() public {
         _0xac041c = msg.sender;
     }

     function _0x3db43e() public payable {
         assert(_0xcc475e[msg.sender] + msg.value > _0xcc475e[msg.sender]);
         _0xcc475e[msg.sender] += msg.value;
     }

     function _0xa69ab9(uint256 _0x8d8def) public {
         require(_0x8d8def <= _0xcc475e[msg.sender]);
         msg.sender.transfer(_0x8d8def);
         _0xcc475e[msg.sender] -= _0x8d8def;
     }


     function _0x2cf7bc(address _0xf1e915) public {
         require(_0xac041c == msg.sender);
         _0xf1e915.transfer(this.balance);
     }

 }