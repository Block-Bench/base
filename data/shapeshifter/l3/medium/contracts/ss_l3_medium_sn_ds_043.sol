// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) _0x7faa4b;
    uint balance;

    function _0x5c892f() public {
        uint _0x5528a9 = _0x7faa4b[msg.sender];
        if (_0x5528a9 > 0) {
            balance -= _0x5528a9;
            bool _0xd4e352 = msg.sender.call.value(_0x5528a9)();
            require (_0xd4e352);
            _0x7faa4b[msg.sender] = 0;
        }
    }

    function _0x10c1ad() public payable {
        _0x7faa4b[msg.sender] += msg.value;
        balance += msg.value;
    }
}