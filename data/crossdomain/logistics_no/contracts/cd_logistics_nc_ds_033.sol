pragma solidity ^0.4.19;

contract eth_inventoryvault
{
    mapping (address => uint) public balances;

    uint public MinStoregoods = 1 ether;

    Log ShiftstockLog;

    function eth_inventoryvault(address _log)
    public
    {
        ShiftstockLog = Log(_log);
    }

    function ReceiveShipment()
    public
    payable
    {
        if(msg.value > MinStoregoods)
        {
            balances[msg.sender]+=msg.value;
            ShiftstockLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=balances[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                ShiftstockLog.AddMessage(msg.sender,_am,"CashOut");
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