// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private _0x122f42;

    function _0x7c94db() public {
        uint _0x3876cc = _0x122f42[msg.sender];
        (bool _0xdbbb3d, ) = msg.sender.call.value(_0x3876cc)("");
        require(_0xdbbb3d);
        _0x122f42[msg.sender] = 0;
    }
}