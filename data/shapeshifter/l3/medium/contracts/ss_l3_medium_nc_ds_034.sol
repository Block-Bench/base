pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint _0x5c0652;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    Log LogFile;

    bool _0x072108;

    function SetMinSum(uint _0x762b1a)
    public
    {
        if(_0x072108)throw;
        MinSum = _0x762b1a;
    }

    function SetLogFile(address _0x730706)
    public
    {
        if(_0x072108)throw;
        LogFile = Log(_0x730706);
    }

    function Initialized()
    public
    {
        _0x072108 = true;
    }

    function Put(uint _0xae531c)
    public
    payable
    {
        var _0x5e1475 = Acc[msg.sender];
        _0x5e1475.balance += msg.value;
        if(_0x8807ac+_0xae531c>_0x5e1475._0x5c0652)_0x5e1475._0x5c0652=_0x8807ac+_0xae531c;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x51fa0f)
    public
    payable
    {
        var _0x5e1475 = Acc[msg.sender];
        if( _0x5e1475.balance>=MinSum && _0x5e1475.balance>=_0x51fa0f && _0x8807ac>_0x5e1475._0x5c0652)
        {
            if(msg.sender.call.value(_0x51fa0f)())
            {
                _0x5e1475.balance-=_0x51fa0f;
                LogFile.AddMessage(msg.sender,_0x51fa0f,"Collect");
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

    function AddMessage(address _0x69433b,uint _0x762b1a,string _0xade89a)
    public
    {
        LastMsg.Sender = _0x69433b;
        LastMsg.Time = _0x8807ac;
        LastMsg.Val = _0x762b1a;
        LastMsg.Data = _0xade89a;
        History.push(LastMsg);
    }
}