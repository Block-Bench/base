// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) _0x3632ce;
    uint balance;

    function _0xda96e1() public {
        uint _0x42ada4 = _0x3632ce[msg.sender];
        if (_0x42ada4 > 0) {
            balance -= _0x42ada4;
            bool _0xa461e0 = msg.sender.call.value(_0x42ada4)();
            require (_0xa461e0);
            _0x3632ce[msg.sender] = 0;
        }
    }

    function _0x89df55() public payable {
        _0x3632ce[msg.sender] += msg.value;
        balance += msg.value;
    }
}