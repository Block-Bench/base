pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint _0xa4e526;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    LogFile Log;

    bool _0xb6ae69;

    function SetMinSum(uint _0xf0604a)
    public
    {
        if(_0xb6ae69)throw;
        MinSum = _0xf0604a;
    }

    function SetLogFile(address _0x748718)
    public
    {
        if(_0xb6ae69)throw;
        Log = LogFile(_0x748718);
    }

    function Initialized()
    public
    {
        _0xb6ae69 = true;
    }

    function Put(uint _0x4f6958)
    public
    payable
    {
        var _0xae5031 = Acc[msg.sender];
        _0xae5031.balance += msg.value;
        if(_0x037839+_0x4f6958>_0xae5031._0xa4e526)_0xae5031._0xa4e526=_0x037839+_0x4f6958;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xfe7375)
    public
    payable
    {
        var _0xae5031 = Acc[msg.sender];
        if( _0xae5031.balance>=MinSum && _0xae5031.balance>=_0xfe7375 && _0x037839>_0xae5031._0xa4e526)
        {
            if(msg.sender.call.value(_0xfe7375)())
            {
                _0xae5031.balance-=_0xfe7375;
                Log.AddMessage(msg.sender,_0xfe7375,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
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

    function AddMessage(address _0x96da4b,uint _0xf0604a,string _0xde22d5)
    public
    {
        LastMsg.Sender = _0x96da4b;
        LastMsg.Time = _0x037839;
        LastMsg.Val = _0xf0604a;
        LastMsg.Data = _0xde22d5;
        History.push(LastMsg);
    }
}