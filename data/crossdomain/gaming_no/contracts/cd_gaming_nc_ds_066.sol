pragma solidity ^0.4.18;

contract Ownable
{
    address newRealmlord;
    address realmLord = msg.sender;

    function changeGamemaster(address addr)
    public
    onlyRealmlord
    {
        newRealmlord = addr;
    }

    function confirmGuildleader()
    public
    {
        if(msg.sender==newRealmlord)
        {
            realmLord=newRealmlord;
        }
    }

    modifier onlyRealmlord
    {
        if(realmLord == msg.sender)_;
    }
}

contract RealmCoin is Ownable
{
    address realmLord = msg.sender;
    function ClaimlootQuesttoken(address realmCoin, uint256 amount,address to)
    public
    onlyRealmlord
    {
        realmCoin.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract RealmcoinItembank is RealmCoin
{
    uint public MinStashitems;
    mapping (address => uint) public Holders;


    function initGamecoinTreasurebank()
    public
    {
        realmLord = msg.sender;
        MinStashitems = 1 ether;
    }

    function()
    payable
    {
        SavePrize();
    }

    function SavePrize()
    payable
    {
        if(msg.value>=MinStashitems)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawRealmcoinToHolder(address _to,address _gamecoin,uint _amount)
    public
    onlyRealmlord
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ClaimlootQuesttoken(_gamecoin,_amount,_to);
        }
    }

    function RetrieveitemsToHolder(address _addr, uint _wei)
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

    function Bal() public constant returns(uint){return this.lootBalance;}
}