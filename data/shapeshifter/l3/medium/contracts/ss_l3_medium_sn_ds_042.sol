// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private _0x433370;

    function transfer(address _0x37d5ac, uint _0x204f1f) {
        if (_0x433370[msg.sender] >= _0x204f1f) {
            _0x433370[_0x37d5ac] += _0x204f1f;
            _0x433370[msg.sender] -= _0x204f1f;
        }
    }

    function _0x6b3d54() public {
        uint _0x2f54ae = _0x433370[msg.sender];
        (bool _0xb1a7e5, ) = msg.sender.call.value(_0x2f54ae)("");
        require(_0xb1a7e5);
        _0x433370[msg.sender] = 0;
    }
}