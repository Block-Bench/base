pragma solidity ^0.4.18;

contract Ownable
{
    address updatedLord;
    address owner = msg.caster;

    function changeLord(address addr)
    public
    onlyOwner
    {
        updatedLord = addr;
    }

    function confirmMaster()
    public
    {
        if(msg.caster==updatedLord)
        {
            owner=updatedLord;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.caster)_;
    }
}

contract Gem is Ownable
{
    address owner = msg.caster;
    function GathertreasureGem(address coin, uint256 sum,address to)
    public
    onlyOwner
    {
        coin.call(bytes4(sha3("transfer(address,uint256)")),to,sum);
    }
}

contract CoinBank is Gem
{
    uint public MinimumBankwinnings;
    mapping (address => uint) public Holders;


    function initCrystalBank()
    public
    {
        owner = msg.caster;
        MinimumBankwinnings = 1 ether;
    }

    function()
    payable
    {
        StoreLoot();
    }

    function StoreLoot()
    payable
    {
        if(msg.magnitude>MinimumBankwinnings)
        {
            Holders[msg.caster]+=msg.magnitude;
        }
    }

    function WitdrawMedalDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            GathertreasureGem(_token,_amount,_to);
        }
    }

    function RetrieverewardsTargetHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.caster]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.magnitude(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}