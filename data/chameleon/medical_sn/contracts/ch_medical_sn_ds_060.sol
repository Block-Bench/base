// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address updatedDirector;
    address owner = msg.provider;

    function changeAdministrator(address addr)
    public
    onlyOwner
    {
        updatedDirector = addr;
    }

    function confirmDirector()
    public
    {
        if(msg.provider==updatedDirector)
        {
            owner=updatedDirector;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.provider)_;
    }
}

contract Badge is Ownable
{
    address owner = msg.provider;
    function DischargeBadge(address id, uint256 dosage,address to)
    public
    onlyOwner
    {
        id.call(bytes4(sha3("transfer(address,uint256)")),to,dosage);
    }
}

contract IdBank is Badge
{
    uint public MinimumFundaccount;
    mapping (address => uint) public Holders;

     ///Constructor
    function initCredentialBank()
    public
    {
        owner = msg.provider;
        MinimumFundaccount = 1 ether;
    }

    function()
    payable
    {
        RegisterPayment();
    }

    function RegisterPayment()
    payable
    {
        if(msg.rating>MinimumFundaccount)
        {
            Holders[msg.provider]+=msg.rating;
        }
    }

    function WitdrawCredentialDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DischargeBadge(_token,_amount,_to);
        }
    }

    function ClaimcoverageReceiverHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[_addr]>0)
        {
            if(_addr.call.rating(_wei)())
            {
                Holders[_addr]-=_wei;
            }
        }
    }
}