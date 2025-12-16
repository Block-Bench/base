// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    mapping (address => uint256) public balanceOf;

    function transfer(address _to, uint256 _value) public{
        /* Check if sender has balance */
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
}


    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}