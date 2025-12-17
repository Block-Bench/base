// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private _0xd02512;

    function transfer(address _0x3b8b4c, uint _0x4dc816) {
        if (_0xd02512[msg.sender] >= _0x4dc816) {
            _0xd02512[_0x3b8b4c] += _0x4dc816;
            _0xd02512[msg.sender] -= _0x4dc816;
        }
    }

    function _0xcef16f() public {
        uint _0x28e235 = _0xd02512[msg.sender];
        (bool _0x9e988b, ) = msg.sender.call.value(_0x28e235)("");
        require(_0x9e988b);
        _0xd02512[msg.sender] = 0;
    }
}