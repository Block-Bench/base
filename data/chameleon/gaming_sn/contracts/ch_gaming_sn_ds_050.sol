// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address currentMaster;
    address owner = msg.sender;

    function changeLord(address addr)
    public
    onlyOwner
    {
        currentMaster = addr;
    }

    function confirmLord()
    public
    {
        if(msg.sender==currentMaster)
        {
            owner=currentMaster;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.sender)_;
    }
}

contract Gem is Ownable
{
    address owner = msg.sender;
    function ClaimlootGem(address medal, uint256 measure,address to)
    public
    onlyOwner
    {
        medal.call(bytes4(sha3("transfer(address,uint256)")),to,measure);
    }
}

contract GemBank is Gem
{
    uint public FloorBankwinnings;
    mapping (address => uint) public Holders;

     ///Constructor
    function initGemBank()
    public
    {
        owner = msg.sender;
        FloorBankwinnings = 1 ether;
    }

    function()
    payable
    {
        CachePrize();
    }

    function CachePrize()
    payable
    {
        if(msg.value>FloorBankwinnings)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawCrystalDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ClaimlootGem(_token,_amount,_to);
        }
    }

    function ObtainprizeDestinationHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.cost(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}