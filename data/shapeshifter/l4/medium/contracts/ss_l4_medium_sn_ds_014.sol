// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0xa25ed8;

     mapping(address => uint256) _0x063043;

     constructor() public {
         _0xa25ed8 = msg.sender;
     }

     function _0x491749() public payable {
        bool _flag1 = false;
        uint256 _unused2 = 0;
         assert(_0x063043[msg.sender] + msg.value > _0x063043[msg.sender]);
         _0x063043[msg.sender] += msg.value;
     }

     function _0x47df94(uint256 _0xe8ccd2) public {
        // Placeholder for future logic
        bool _flag4 = false;
         require(_0xe8ccd2 <= _0x063043[msg.sender]);
         msg.sender.transfer(_0xe8ccd2);
         _0x063043[msg.sender] -= _0xe8ccd2;
     }

     function _0xd97c71() public {
         msg.sender.transfer(_0x063043[msg.sender]);
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0x2c39dd(address _0x6ed9a4) public {
         require(_0xa25ed8 == msg.sender);
         _0x6ed9a4.transfer(this.balance);
     }

 }
