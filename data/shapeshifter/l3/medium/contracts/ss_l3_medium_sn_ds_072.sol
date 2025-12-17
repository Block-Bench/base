// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract _0xe2fe7d {
    mapping(address => uint256) public _0xcdb50b;

    function () payable public {
        _0xcdb50b[msg.sender] += msg.value;
    }

    function _0x5f50a4() public {
        msg.sender.call.value(_0xcdb50b[msg.sender])();
        _0xcdb50b[msg.sender] = 0;
    }
}
