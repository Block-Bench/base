// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private _0xbf268e;

    function _0x9efad5() public {
        uint _0xffe1a8 = _0xbf268e[msg.sender];
        (bool _0x0600d8, ) = msg.sender.call.value(_0xffe1a8)("");
        require(_0x0600d8);
        _0xbf268e[msg.sender] = 0;
    }
}