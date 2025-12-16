pragma solidity ^0.4.19;

contract Ownable
{
    address newDungeonmaster;
    address gamemaster = msg.sender;

    function changeDungeonmaster(address addr)
    public
    onlyGamemaster
    {
        newDungeonmaster = addr;
    }

    function confirmDungeonmaster()
    public
    {
        if(msg.sender==newDungeonmaster)
        {
            gamemaster=newDungeonmaster;
        }
    }

    modifier onlyGamemaster
    {
        if(gamemaster == msg.sender)_;
    }
}

contract QuestToken is Ownable
{
    address gamemaster = msg.sender;
    function CollecttreasureGoldtoken(address goldToken, uint256 amount,address to)
    public
    onlyGamemaster
    {
        goldToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract RealmcoinTreasurebank is QuestToken
{
    uint public MinSaveprize;
    mapping (address => uint) public Holders;


    function initGamecoinGoldbank()
    public
    {
        gamemaster = msg.sender;
        MinSaveprize = 1 ether;
    }

    function()
    payable
    {
        StoreLoot();
    }

    function StoreLoot()
    payable
    {
        if(msg.value>MinSaveprize)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawQuesttokenToHolder(address _to,address _gamecoin,uint _amount)
    public
    onlyGamemaster
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            CollecttreasureGoldtoken(_gamecoin,_amount,_to);
        }
    }

    function ClaimlootToHolder(address _addr, uint _wei)
    public
    onlyGamemaster
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