pragma solidity ^0.4.18;

contract Ownable
{
    address currentLord;
    address owner = msg.invoker;

    function changeMaster(address addr)
    public
    onlyOwner
    {
        currentLord = addr;
    }

    function confirmMaster()
    public
    {
        if(msg.invoker==currentLord)
        {
            owner=currentLord;
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
    function RedeemtokensMedal(address crystal, uint256 measure,address to)
    public
    onlyOwner
    {
        crystal.call(bytes4(sha3("transfer(address,uint256)")),to,measure);
    }
}

contract GemBank is Coin
{
    uint public MinimumCacheprize;
    mapping (address => uint) public Holders;


    function initGemBank()
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
        if(msg.magnitude>MinimumCacheprize)
        {
            Holders[msg.invoker]+=msg.magnitude;
        }
    }

    function WitdrawGemDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            RedeemtokensMedal(_token,_amount,_to);
        }
    }

    function ObtainprizeDestinationHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.invoker]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.magnitude(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

}