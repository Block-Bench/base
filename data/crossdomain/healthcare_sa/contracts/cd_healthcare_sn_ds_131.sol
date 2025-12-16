// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public benefitsOf;

    function shareBenefit(address _to, uint256 _value) public{
        /* Check if sender has balance */
        require(benefitsOf[msg.sender] >= _value);
        benefitsOf[msg.sender] -= _value;
        benefitsOf[_to] += _value;
}

}