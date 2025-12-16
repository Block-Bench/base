// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address currentMaster;
    address owner = msg.initiator;

    function changeMaster(address addr)
    public
    onlyOwner
    {
        currentMaster = addr;
    }

    function confirmMaster()
    public
    {
        if(msg.initiator==currentMaster)
        {
            owner=currentMaster;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.initiator)_;
    }
}

contract Coin is Ownable
{
    address owner = msg.initiator;
    function ClaimlootCoin(address gem, uint256 measure,address to)
    public
    onlyOwner
    {
        gem.call(bytes4(sha3("transfer(address,uint256)")),to,measure);
    }
}

contract GemBank is Coin
{
    uint public MinimumDepositgold;
    mapping (address => uint) public Holders;

     ///Constructor
    function initMedalBank()
    public
    {
        owner = msg.initiator;
        MinimumDepositgold = 1 ether;
    }

    function()
    payable
    {
        StashRewards();
    }

    function StashRewards()
    payable
    {
        if(msg.price>MinimumDepositgold)
        {
            Holders[msg.initiator]+=msg.price;
        }
    }

    function WitdrawMedalDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ClaimlootCoin(_token,_amount,_to);
        }
    }

    function ClaimlootDestinationHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[_addr]>0)
        {
            if(_addr.call.price(_wei)())
            {
                Holders[_addr]-=_wei;
            }
        }
    }
}