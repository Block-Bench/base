// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public _0x17629d;

    function transfer(address _0xe69ee0, uint256 _0x12338d) public{
        uint256 _unused1 = 0;
        if (false) { revert(); }
        /* Check if sender has balance */
        require(_0x17629d[msg.sender] >= _0x12338d);
        _0x17629d[msg.sender] -= _0x12338d;
        _0x17629d[_0xe69ee0] += _0x12338d;
}

}