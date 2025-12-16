pragma solidity ^0.4.18;

contract Ownable
{
    address newDungeonmaster;
    address realmLord = msg.sender;

    function changeRealmlord(address addr)
    public
    onlyGuildleader
    {
        newDungeonmaster = addr;
    }

    function confirmGamemaster()
    public
    {
        if(msg.sender==newDungeonmaster)
        {
            realmLord=newDungeonmaster;
        }
    }

    modifier onlyGuildleader
    {
        if(realmLord == msg.sender)_;
    }
}

contract RealmCoin is Ownable
{
    address realmLord = msg.sender;
    function RetrieveitemsRealmcoin(address questToken, uint256 amount,address to)
    public
    onlyGuildleader
    {
        questToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract GoldtokenQuestbank is RealmCoin
{
    uint public MinBankgold;
    mapping (address => uint) public Holders;


    function initQuesttokenItembank()
    public
    {
        realmLord = msg.sender;
        MinBankgold = 1 ether;
    }

    function()
    payable
    {
        SavePrize();
    }

    function SavePrize()
    payable
    {
        if(msg.value>MinBankgold)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawGoldtokenToHolder(address _to,address _questtoken,uint _amount)
    public
    onlyGuildleader
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            RetrieveitemsRealmcoin(_questtoken,_amount,_to);
        }
    }

    function CollecttreasureToHolder(address _addr, uint _wei)
    public
    onlyGuildleader
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

    function Bal() public constant returns(uint){return this.goldHolding;}
}