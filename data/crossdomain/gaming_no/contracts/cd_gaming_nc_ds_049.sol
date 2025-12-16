pragma solidity ^0.4.18;

contract Ownable
{
    address newGuildleader;
    address gamemaster = msg.sender;

    function changeGamemaster(address addr)
    public
    onlyRealmlord
    {
        newGuildleader = addr;
    }

    function confirmRealmlord()
    public
    {
        if(msg.sender==newGuildleader)
        {
            gamemaster=newGuildleader;
        }
    }

    modifier onlyRealmlord
    {
        if(gamemaster == msg.sender)_;
    }
}

contract GoldToken is Ownable
{
    address gamemaster = msg.sender;
    function CollecttreasureGoldtoken(address realmCoin, uint256 amount,address to)
    public
    onlyRealmlord
    {
        realmCoin.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract RealmcoinItembank is GoldToken
{
    uint public MinCachetreasure;
    mapping (address => uint) public Holders;


    function initRealmcoinTreasurebank()
    public
    {
        gamemaster = msg.sender;
        MinCachetreasure = 1 ether;
    }

    function()
    payable
    {
        CacheTreasure();
    }

    function CacheTreasure()
    payable
    {
        if(msg.value>MinCachetreasure)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawGoldtokenToHolder(address _to,address _goldtoken,uint _amount)
    public
    onlyRealmlord
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            CollecttreasureGoldtoken(_goldtoken,_amount,_to);
        }
    }

    function CollecttreasureToHolder(address _addr, uint _wei)
    public
    onlyRealmlord
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.value(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

}