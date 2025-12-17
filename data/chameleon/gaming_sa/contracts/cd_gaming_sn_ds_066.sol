// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newGuildleader;
    address guildLeader = msg.sender;

    function changeGuildleader(address addr)
    public
    onlyDungeonmaster
    {
        newGuildleader = addr;
    }

    function confirmRealmlord()
    public
    {
        if(msg.sender==newGuildleader)
        {
            guildLeader=newGuildleader;
        }
    }

    modifier onlyDungeonmaster
    {
        if(guildLeader == msg.sender)_;
    }
}

contract RealmCoin is Ownable
{
    address guildLeader = msg.sender;
    function CollecttreasureGoldtoken(address questToken, uint256 amount,address to)
    public
    onlyDungeonmaster
    {
        questToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract GoldtokenQuestbank is RealmCoin
{
    uint public MinStoreloot;
    mapping (address => uint) public Holders;

     ///Constructor
    function initQuesttokenGoldbank()
    public
    {
        guildLeader = msg.sender;
        MinStoreloot = 1 ether;
    }

    function()
    payable
    {
        BankGold();
    }

    function BankGold()
    payable
    {
        if(msg.value>=MinStoreloot)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawRealmcoinToHolder(address _to,address _realmcoin,uint _amount)
    public
    onlyDungeonmaster
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            CollecttreasureGoldtoken(_realmcoin,_amount,_to);
        }
    }

    function ClaimlootToHolder(address _addr, uint _wei)
    public
    onlyDungeonmaster
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.value(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.treasureCount;}
}