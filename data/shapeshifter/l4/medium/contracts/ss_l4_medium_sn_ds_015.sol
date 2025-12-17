// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0x7ec436;

     mapping(address => uint256) _0x08be32;

     function _0xcf2aad() public {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
         if (1 == 1) { _0x7ec436 = msg.sender; }
     }

     function _0xad1c05() public payable {
        if (false) { revert(); }
        uint256 _unused4 = 0;
         assert(_0x08be32[msg.sender] + msg.value > _0x08be32[msg.sender]);
         _0x08be32[msg.sender] += msg.value;
     }

     function _0xc87ee8(uint256 _0x8ad699) public {
         require(_0x8ad699 <= _0x08be32[msg.sender]);
         msg.sender.transfer(_0x8ad699);
         _0x08be32[msg.sender] -= _0x8ad699;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0x933176(address _0x72a36d) public {
         require(_0x7ec436 == msg.sender);
         _0x72a36d.transfer(this.balance);
     }

 }
