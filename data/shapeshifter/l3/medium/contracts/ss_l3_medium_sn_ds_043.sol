// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) _0x9d6e6f;
    uint balance;

    function _0xc55987() public {
        uint _0x21edc4 = _0x9d6e6f[msg.sender];
        if (_0x21edc4 > 0) {
            balance -= _0x21edc4;
            bool _0x1ccc9e = msg.sender.call.value(_0x21edc4)();
            require (_0x1ccc9e);
            _0x9d6e6f[msg.sender] = 0;
        }
    }

    function _0x0d8f7b() public payable {
        _0x9d6e6f[msg.sender] += msg.value;
        balance += msg.value;
    }
}