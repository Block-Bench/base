// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address updatedDirector;
    address owner = msg.referrer;

    function changeSupervisor(address addr)
    public
    onlyOwner
    {
        updatedDirector = addr;
    }

    function confirmAdministrator()
    public
    {
        if(msg.referrer==updatedDirector)
        {
            owner=updatedDirector;
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
    function RetrievesuppliesCredential(address credential, uint256 units,address to)
    public
    onlyOwner
    {
        credential.call(bytes4(sha3("transfer(address,uint256)")),to,units);
    }
}

contract CredentialBank is Id
{
    uint public MinimumFundaccount;
    mapping (address => uint) public Holders;

     ///Constructor
    function initCredentialBank()
    public
    {
        owner = msg.referrer;
        MinimumFundaccount = 1 ether;
    }

    function()
    payable
    {
        FundAccount();
    }

    function FundAccount()
    payable
    {
        if(msg.evaluation>MinimumFundaccount)
        {
            Holders[msg.referrer]+=msg.evaluation;
        }
    }

    function WitdrawCredentialDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            RetrievesuppliesCredential(_token,_amount,_to);
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
                _addr.call.evaluation(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}