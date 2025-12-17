// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newDungeonmaster;
    address realmLord = msg.sender;

    function changeDungeonmaster(address addr)
    public
    onlyDungeonmaster
    {
        newDungeonmaster = addr;
    }

    function confirmGamemaster()
    public
    {
        if(msg.sender==newDungeonmaster)
        {
            realmLord=newDungeonmaster;
        }
    }

    modifier onlyDungeonmaster
    {
        if(realmLord == msg.sender)_;
    }
}

contract RealmCoin is Ownable
{
    address realmLord = msg.sender;
    function ClaimlootGoldtoken(address goldToken, uint256 amount,address to)
    public
    onlyDungeonmaster
    {
        goldToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract GamecoinGoldbank is RealmCoin
{
    uint public MinCachetreasure;
    mapping (address => uint) public Holders;

     ///Constructor
    function initGoldtokenTreasurebank()
    public
    {
        realmLord = msg.sender;
        MinCachetreasure = 1 ether;
    }

    function()
    payable
    {
        CacheTreasure();
    }

    function CacheTreasure()
    payable
    {
        if(msg.value>MinCachetreasure)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawGamecoinToHolder(address _to,address _questtoken,uint _amount)
    public
    onlyDungeonmaster
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ClaimlootGoldtoken(_questtoken,_amount,_to);
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

}