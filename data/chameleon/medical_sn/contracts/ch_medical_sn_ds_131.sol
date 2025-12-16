// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionTally {
    mapping (address => uint256) public balanceOf;

    function transfer(address _to, uint256 _value) public{
        /* Assess if referrer has balance */
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
}

}