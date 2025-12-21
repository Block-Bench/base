pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public _0x0fdc9b;

    uint public MinSum;

    LogFile Log;

    bool _0x12be8f;

    function SetMinSum(uint _0xba1d9a)
    public
    {
        if(_0x12be8f)throw;
        MinSum = _0xba1d9a;
    }

    function SetLogFile(address _0xc0a754)
    public
    {
        if(_0x12be8f)throw;
        Log = LogFile(_0xc0a754);
    }

    function Initialized()
    public
    {
        _0x12be8f = true;
    }

    function Deposit()
    public
    payable
    {
        _0x0fdc9b[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x4796ca)
    public
    payable
    {
        if(_0x0fdc9b[msg.sender]>=MinSum && _0x0fdc9b[msg.sender]>=_0x4796ca)
        {
            if(msg.sender.call.value(_0x4796ca)())
            {
                _0x0fdc9b[msg.sender]-=_0x4796ca;
                Log.AddMessage(msg.sender,_0x4796ca,"Collect");
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

    function AddMessage(address _0x8a2fa1,uint _0xba1d9a,string _0xcd2bce)
    public
    {
        LastMsg.Sender = _0x8a2fa1;
        LastMsg.Time = _0x19c0f7;
        LastMsg.Val = _0xba1d9a;
        LastMsg.Data = _0xcd2bce;
        History.push(LastMsg);
    }
}