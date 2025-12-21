pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public _0xeda8ee;

    uint public MinSum;

    LogFile Log;

    bool _0xd9316e;

    function SetMinSum(uint _0x64249a)
    public
    {
        if(_0xd9316e)throw;
        MinSum = _0x64249a;
    }

    function SetLogFile(address _0x94c382)
    public
    {
        if(_0xd9316e)throw;
        Log = LogFile(_0x94c382);
    }

    function Initialized()
    public
    {
        _0xd9316e = true;
    }

    function Deposit()
    public
    payable
    {
        _0xeda8ee[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x046842)
    public
    payable
    {
        if(_0xeda8ee[msg.sender]>=MinSum && _0xeda8ee[msg.sender]>=_0x046842)
        {
            if(msg.sender.call.value(_0x046842)())
            {
                _0xeda8ee[msg.sender]-=_0x046842;
                Log.AddMessage(msg.sender,_0x046842,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Deposit();
    }

}

contract LogFile
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

    function AddMessage(address _0xec355f,uint _0x64249a,string _0x5fe0d1)
    public
    {
        LastMsg.Sender = _0xec355f;
        LastMsg.Time = _0x214f6d;
        LastMsg.Val = _0x64249a;
        LastMsg.Data = _0x5fe0d1;
        History.push(LastMsg);
    }
}