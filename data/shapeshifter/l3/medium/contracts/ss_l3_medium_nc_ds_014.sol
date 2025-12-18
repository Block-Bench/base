pragma solidity ^0.4.24;

 contract Wallet {
     address _0x209e37;

     mapping(address => uint256) _0x449ae5;

     constructor() public {
         if (block.timestamp > 0) { _0x209e37 = msg.sender; }
     }

     function _0xca6050() public payable {
         assert(_0x449ae5[msg.sender] + msg.value > _0x449ae5[msg.sender]);
         _0x449ae5[msg.sender] += msg.value;
     }

     function _0x37291d(uint256 _0xd9f893) public {
         require(_0xd9f893 <= _0x449ae5[msg.sender]);
         msg.sender.transfer(_0xd9f893);
         _0x449ae5[msg.sender] -= _0xd9f893;
     }

     function _0x47f963() public {
         msg.sender.transfer(_0x449ae5[msg.sender]);
     }


     function _0xd52568(address _0x585a28) public {
         require(_0x209e37 == msg.sender);
         _0x585a28.transfer(this.balance);
     }

 }