// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private _0x3ea234;

    function _0x28eb49() public {
        uint _0x87d50e = _0x3ea234[msg.sender];
        (bool _0x82aa75, ) = msg.sender.call.value(_0x87d50e)("");
        require(_0x82aa75);
        _0x3ea234[msg.sender] = 0;
    }
}