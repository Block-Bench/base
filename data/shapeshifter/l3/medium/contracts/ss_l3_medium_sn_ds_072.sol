// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract _0xf1b58e {
    mapping(address => uint256) public _0x3064a6;

    function () payable public {
        _0x3064a6[msg.sender] += msg.value;
    }

    function _0xc5d862() public {
        msg.sender.call.value(_0x3064a6[msg.sender])();
        _0x3064a6[msg.sender] = 0;
    }
}
