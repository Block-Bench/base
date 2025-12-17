// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public _0x78bcf0;

    function transfer(address _0x2f7b50, uint256 _0xceac7d) public{
        /* Check if sender has balance */
        require(_0x78bcf0[msg.sender] >= _0xceac7d);
        _0x78bcf0[msg.sender] -= _0xceac7d;
        _0x78bcf0[_0x2f7b50] += _0xceac7d;
}

}