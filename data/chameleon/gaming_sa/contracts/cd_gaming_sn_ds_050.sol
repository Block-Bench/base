// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newGamemaster;
    address realmLord = msg.sender;

    function changeDungeonmaster(address addr)
    public
    onlyDungeonmaster
    {
        newGamemaster = addr;
    }

    function confirmDungeonmaster()
    public
    {
        if(msg.sender==newGamemaster)
        {
            realmLord=newGamemaster;
        }
    }

    modifier onlyDungeonmaster
    {
        if(realmLord == msg.sender)_;
    }
}

contract QuestToken is Ownable
{
    address realmLord = msg.sender;
    function RetrieveitemsRealmcoin(address questToken, uint256 amount,address to)
    public
    onlyDungeonmaster
    {
        questToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract RealmcoinQuestbank is QuestToken
{
    uint public MinCachetreasure;
    mapping (address => uint) public Holders;

     ///Constructor
    function initRealmcoinGoldbank()
    public
    {
        realmLord = msg.sender;
        MinCachetreasure = 1 ether;
    }

    function()
    payable
    {
        BankGold();
    }

    function BankGold()
    payable
    {
        if(msg.value>MinCachetreasure)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawGamecoinToHolder(address _to,address _gamecoin,uint _amount)
    public
    onlyDungeonmaster
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            RetrieveitemsRealmcoin(_gamecoin,_amount,_to);
        }
    }

    function CollecttreasureToHolder(address _addr, uint _wei)
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