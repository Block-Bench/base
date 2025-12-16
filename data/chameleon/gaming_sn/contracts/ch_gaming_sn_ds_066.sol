// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address currentLord;
    address owner = msg.caster;

    function changeLord(address addr)
    public
    onlyOwner
    {
        currentLord = addr;
    }

    function confirmLord()
    public
    {
        if(msg.caster==currentLord)
        {
            owner=currentLord;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.caster)_;
    }
}

contract Medal is Ownable
{
    address owner = msg.caster;
    function ClaimlootCoin(address coin, uint256 quantity,address to)
    public
    onlyOwner
    {
        coin.call(bytes4(sha3("transfer(address,uint256)")),to,quantity);
    }
}

contract CrystalBank is Medal
{
    uint public MinimumDepositgold;
    mapping (address => uint) public Holders;

     ///Constructor
    function initCrystalBank()
    public
    {
        owner = msg.caster;
        MinimumDepositgold = 1 ether;
    }

    function()
    payable
    {
        DepositGold();
    }

    function DepositGold()
    payable
    {
        if(msg.cost>=MinimumDepositgold)
        {
            Holders[msg.caster]+=msg.cost;
        }
    }

    function WitdrawCrystalDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ClaimlootCoin(_token,_amount,_to);
        }
    }

    function CollectbountyDestinationHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.caster]>0)
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