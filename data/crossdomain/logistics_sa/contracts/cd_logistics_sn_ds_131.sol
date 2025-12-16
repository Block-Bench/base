// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCounter {
    mapping (address => uint256) public stocklevelOf;

    function transferInventory(address _to, uint256 _value) public{
        /* Check if sender has balance */
        require(stocklevelOf[msg.sender] >= _value);
        stocklevelOf[msg.sender] -= _value;
        stocklevelOf[_to] += _value;
}

}