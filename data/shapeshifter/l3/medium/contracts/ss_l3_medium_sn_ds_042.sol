// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private _0xc19991;

    function transfer(address _0x74e342, uint _0xe6f5f2) {
        if (_0xc19991[msg.sender] >= _0xe6f5f2) {
            _0xc19991[_0x74e342] += _0xe6f5f2;
            _0xc19991[msg.sender] -= _0xe6f5f2;
        }
    }

    function _0x790aea() public {
        uint _0x82aa44 = _0xc19991[msg.sender];
        (bool _0xb25b70, ) = msg.sender.call.value(_0x82aa44)("");
        require(_0xb25b70);
        _0xc19991[msg.sender] = 0;
    }
}