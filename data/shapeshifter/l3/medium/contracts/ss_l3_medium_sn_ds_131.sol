// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public _0x1229c4;

    function transfer(address _0x079e34, uint256 _0x482e07) public{
        /* Check if sender has balance */
        require(_0x1229c4[msg.sender] >= _0x482e07);
        _0x1229c4[msg.sender] -= _0x482e07;
        _0x1229c4[_0x079e34] += _0x482e07;
}

}