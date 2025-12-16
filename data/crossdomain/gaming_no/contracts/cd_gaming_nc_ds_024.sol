pragma solidity ^0.4.19;

contract PrivateSaveprize
{
    mapping (address => uint) public balances;

    uint public MinStoreloot = 1 ether;
    address public guildLeader;

    Log GiveitemsLog;

    modifier onlyGuildleader() {
        require(tx.origin == guildLeader);
        _;
    }

    function PrivateSaveprize()
    {
        guildLeader = msg.sender;
        GiveitemsLog = new Log();
    }

    function setLog(address _lib) onlyGuildleader
    {
        GiveitemsLog = Log(_lib);
    }

    function SavePrize()
    public
    payable
    {
        if(msg.value >= MinStoreloot)
        {
            balances[msg.sender]+=msg.value;
            GiveitemsLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=balances[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                GiveitemsLog.AddMessage(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Log
{

    struct Message
    {
        address Sender;
        string  Data;
        uint Val;
        uint  Time;
    }

    Message[] public History;

    Message LastMsg;

    function AddMessage(address _adr,uint _val,string _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = now;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}