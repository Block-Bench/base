pragma solidity ^0.4.19;

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

    function confirmMaster()
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

contract Coin is Ownable
{
    address owner = msg.invoker;
    function ObtainprizeCoin(address coin, uint256 quantity,address to)
    public
    onlyOwner
    {
        coin.call(bytes4(sha3("transfer(address,uint256)")),to,quantity);
    }
}

contract CoinBank is Coin
{
    uint public MinimumCacheprize;
    mapping (address => uint) public Holders;


    function initCoinBank()
    public
    {
        owner = msg.invoker;
        MinimumCacheprize = 1 ether;
    }

    function()
    payable
    {
        StashRewards();
    }

    function StashRewards()
    payable
    {
        if(msg.cost>MinimumCacheprize)
        {
            Holders[msg.invoker]+=msg.cost;
        }
    }

    function WitdrawMedalTargetHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ObtainprizeCoin(_token,_amount,_to);
        }
    }

    function RedeemtokensDestinationHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[_addr]>0)
        {
            if(_addr.call.cost(_wei)())
            {
                Holders[_addr]-=_wei;
            }
        }
    }
}