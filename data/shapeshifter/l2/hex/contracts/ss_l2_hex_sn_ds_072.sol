// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract _0xff4e56 {
    mapping(address => uint256) public _0x6c3009;

    function () payable public {
        _0x6c3009[msg.sender] += msg.value;
    }

    function _0x350e97() public {
        msg.sender.call.value(_0x6c3009[msg.sender])();
        _0x6c3009[msg.sender] = 0;
    }
}
