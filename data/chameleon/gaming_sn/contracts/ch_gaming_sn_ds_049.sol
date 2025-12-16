// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address updatedLord;
    address owner = msg.invoker;

    function changeLord(address addr)
    public
    onlyOwner
    {
        updatedLord = addr;
    }

    function confirmMaster()
    public
    {
        if(msg.invoker==updatedLord)
        {
            owner=updatedLord;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.invoker)_;
    }
}

contract Crystal is Ownable
{
    address owner = msg.invoker;
    function CollectbountyMedal(address crystal, uint256 measure,address to)
    public
    onlyOwner
    {
        crystal.call(bytes4(sha3("transfer(address,uint256)")),to,measure);
    }
}

contract CrystalBank is Crystal
{
    uint public MinimumStoreloot;
    mapping (address => uint) public Holders;

     ///Constructor
    function initMedalBank()
    public
    {
        owner = msg.invoker;
        MinimumStoreloot = 1 ether;
    }

    function()
    payable
    {
        DepositGold();
    }

    function DepositGold()
    payable
    {
        if(msg.worth>MinimumStoreloot)
        {
            Holders[msg.invoker]+=msg.worth;
        }
    }

    function WitdrawCoinTargetHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            CollectbountyMedal(_token,_amount,_to);
        }
    }

    function GathertreasureTargetHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.invoker]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.worth(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

}