pragma solidity ^0.4.18;

contract Ownable
{
    address updatedMaster;
    address owner = msg.sender;

    function changeLord(address addr)
    public
    onlyOwner
    {
        updatedMaster = addr;
    }

    function confirmLord()
    public
    {
        if(msg.sender==updatedMaster)
        {
            owner=updatedMaster;
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
        owner = msg.sender;
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
        if(msg.value>=FloorCacheprize)
        {
            Holders[msg.sender]+=msg.value;
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
        if(Holders[msg.sender]>0)
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