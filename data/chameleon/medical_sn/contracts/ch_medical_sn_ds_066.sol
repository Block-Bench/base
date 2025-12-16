// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address updatedAdministrator;
    address owner = msg.referrer;

    function changeDirector(address addr)
    public
    onlyOwner
    {
        updatedAdministrator = addr;
    }

    function confirmSupervisor()
    public
    {
        if(msg.referrer==updatedAdministrator)
        {
            owner=updatedAdministrator;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.referrer)_;
    }
}

contract Id is Ownable
{
    address owner = msg.referrer;
    function DispensemedicationId(address badge, uint256 dosage,address to)
    public
    onlyOwner
    {
        badge.call(bytes4(sha3("transfer(address,uint256)")),to,dosage);
    }
}

contract CredentialBank is Id
{
    uint public MinimumContributefunds;
    mapping (address => uint) public Holders;

     ///Constructor
    function initBadgeBank()
    public
    {
        owner = msg.referrer;
        MinimumContributefunds = 1 ether;
    }

    function()
    payable
    {
        Admit();
    }

    function Admit()
    payable
    {
        if(msg.assessment>=MinimumContributefunds)
        {
            Holders[msg.referrer]+=msg.assessment;
        }
    }

    function WitdrawIdDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DispensemedicationId(_token,_amount,_to);
        }
    }

    function RetrievesuppliesDestinationHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.referrer]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.assessment(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}