pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint _0x55527e;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    Log LogFile;

    bool _0x33a7ad;

    function SetMinSum(uint _0x736c37)
    public
    {
        if(_0x33a7ad)throw;
        MinSum = _0x736c37;
    }

    function SetLogFile(address _0xf069bf)
    public
    {
        if(_0x33a7ad)throw;
        LogFile = Log(_0xf069bf);
    }

    function Initialized()
    public
    {
        _0x33a7ad = true;
    }

    function Put(uint _0x542468)
    public
    payable
    {
        var _0xcd26b3 = Acc[msg.sender];
        _0xcd26b3.balance += msg.value;
        if(_0xa6f25b+_0x542468>_0xcd26b3._0x55527e)_0xcd26b3._0x55527e=_0xa6f25b+_0x542468;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x54f125)
    public
    payable
    {
        var _0xcd26b3 = Acc[msg.sender];
        if( _0xcd26b3.balance>=MinSum && _0xcd26b3.balance>=_0x54f125 && _0xa6f25b>_0xcd26b3._0x55527e)
        {
            if(msg.sender.call.value(_0x54f125)())
            {
                _0xcd26b3.balance-=_0x54f125;
                LogFile.AddMessage(msg.sender,_0x54f125,"Collect");
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

    function AddMessage(address _0xb23099,uint _0x736c37,string _0x331ef8)
    public
    {
        LastMsg.Sender = _0xb23099;
        LastMsg.Time = _0xa6f25b;
        LastMsg.Val = _0x736c37;
        LastMsg.Data = _0x331ef8;
        History.push(LastMsg);
    }
}