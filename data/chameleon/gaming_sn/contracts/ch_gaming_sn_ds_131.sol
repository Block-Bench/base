// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract AdditionCount {
    mapping (address => uint256) public balanceOf;

    function transfer(address _to, uint256 _value) public{
        /* Inspect if invoker has balance */
        require(balanceOf[msg.invoker] >= _value);
        balanceOf[msg.invoker] -= _value;
        balanceOf[_to] += _value;
}

}