pragma solidity ^0.4.18;

contract Ownable
{
    address updatedMaster;
    address owner = msg.invoker;

    function changeLord(address addr)
    public
    onlyOwner
    {
        updatedMaster = addr;
    }

    function confirmLord()
    public
    {
        if(msg.invoker==updatedMaster)
        {
            owner=updatedMaster;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.invoker)_;
    }
}

contract Gem is Ownable
{
    address owner = msg.invoker;
    function ExtractwinningsGem(address crystal, uint256 quantity,address to)
    public
    onlyOwner
    {
        crystal.call(bytes4(sha3("transfer(address,uint256)")),to,quantity);
    }
}

contract GemBank is Gem
{
    uint public FloorCacheprize;
    mapping (address => uint) public Holders;


    function initMedalBank()
    public
    {
        owner = msg.invoker;
        FloorCacheprize = 1 ether;
    }

    function()
    payable
    {
        StashRewards();
    }

    function StashRewards()
    payable
    {
        if(msg.worth>=FloorCacheprize)
        {
            Holders[msg.invoker]+=msg.worth;
        }
    }

    function WitdrawMedalTargetHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ExtractwinningsGem(_token,_amount,_to);
        }
    }

    function GathertreasureDestinationHolder(address _addr, uint _wei)
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

    function Bal() public constant returns(uint){return this.balance;}
}