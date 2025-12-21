pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint _0x2f6a67;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    LogFile Log;

    bool _0x43f50e;

    function SetMinSum(uint _0xc15318)
    public
    {
        if(_0x43f50e)throw;
        MinSum = _0xc15318;
    }

    function SetLogFile(address _0x1e6787)
    public
    {
        if(_0x43f50e)throw;
        Log = LogFile(_0x1e6787);
    }

    function Initialized()
    public
    {
        _0x43f50e = true;
    }

    function Put(uint _0x070543)
    public
    payable
    {
        var _0xce9644 = Acc[msg.sender];
        _0xce9644.balance += msg.value;
        if(_0xb44d85+_0x070543>_0xce9644._0x2f6a67)_0xce9644._0x2f6a67=_0xb44d85+_0x070543;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x53d9e2)
    public
    payable
    {
        var _0xce9644 = Acc[msg.sender];
        if( _0xce9644.balance>=MinSum && _0xce9644.balance>=_0x53d9e2 && _0xb44d85>_0xce9644._0x2f6a67)
        {
            if(msg.sender.call.value(_0x53d9e2)())
            {
                _0xce9644.balance-=_0x53d9e2;
                Log.AddMessage(msg.sender,_0x53d9e2,"Collect");
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

    function AddMessage(address _0x452320,uint _0xc15318,string _0x97d1e2)
    public
    {
        LastMsg.Sender = _0x452320;
        LastMsg.Time = _0xb44d85;
        LastMsg.Val = _0xc15318;
        LastMsg.Data = _0x97d1e2;
        History.push(LastMsg);
    }
}