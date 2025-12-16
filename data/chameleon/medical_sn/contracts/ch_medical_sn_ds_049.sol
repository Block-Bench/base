// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address currentSupervisor;
    address owner = msg.provider;

    function changeAdministrator(address addr)
    public
    onlyOwner
    {
        currentSupervisor = addr;
    }

    function confirmSupervisor()
    public
    {
        if(msg.provider==currentSupervisor)
        {
            owner=currentSupervisor;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.provider)_;
    }
}

contract Id is Ownable
{
    address owner = msg.provider;
    function ObtaincareBadge(address id, uint256 units,address to)
    public
    onlyOwner
    {
        id.call(bytes4(sha3("transfer(address,uint256)")),to,units);
    }
}

contract BadgeBank is Id
{
    uint public FloorContributefunds;
    mapping (address => uint) public Holders;

     ///Constructor
    function initIdBank()
    public
    {
        owner = msg.provider;
        FloorContributefunds = 1 ether;
    }

    function()
    payable
    {
        Admit();
    }

    function Admit()
    payable
    {
        if(msg.assessment>FloorContributefunds)
        {
            Holders[msg.provider]+=msg.assessment;
        }
    }

    function WitdrawBadgeReceiverHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ObtaincareBadge(_token,_amount,_to);
        }
    }

    function ObtaincareReceiverHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.provider]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.assessment(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

}