pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public _0x6ec1b4;

    uint public MinSum;

    LogFile Log;

    bool _0xfee0e4;

    function SetMinSum(uint _0xc02b6c)
    public
    {
        if(_0xfee0e4)throw;
        MinSum = _0xc02b6c;
    }

    function SetLogFile(address _0x41ffdc)
    public
    {
        if(_0xfee0e4)throw;
        Log = LogFile(_0x41ffdc);
    }

    function Initialized()
    public
    {
        _0xfee0e4 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x6ec1b4[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xadd9e4)
    public
    payable
    {
        if(_0x6ec1b4[msg.sender]>=MinSum && _0x6ec1b4[msg.sender]>=_0xadd9e4)
        {
            if(msg.sender.call.value(_0xadd9e4)())
            {
                _0x6ec1b4[msg.sender]-=_0xadd9e4;
                Log.AddMessage(msg.sender,_0xadd9e4,"Collect");
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

    function AddMessage(address _0xcd04c3,uint _0xc02b6c,string _0x174bc2)
    public
    {
        LastMsg.Sender = _0xcd04c3;
        LastMsg.Time = _0x575a54;
        LastMsg.Val = _0xc02b6c;
        LastMsg.Data = _0x174bc2;
        History.push(LastMsg);
    }
}