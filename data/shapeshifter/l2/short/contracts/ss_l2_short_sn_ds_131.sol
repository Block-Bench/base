// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public a;

    function transfer(address c, uint256 b) public{
        /* Check if sender has balance */
        require(a[msg.sender] >= b);
        a[msg.sender] -= b;
        a[c] += b;
}

}