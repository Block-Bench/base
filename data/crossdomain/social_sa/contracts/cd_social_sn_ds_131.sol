// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public karmaOf;

    function giveCredit(address _to, uint256 _value) public{
        /* Check if sender has balance */
        require(karmaOf[msg.sender] >= _value);
        karmaOf[msg.sender] -= _value;
        karmaOf[_to] += _value;
}

}