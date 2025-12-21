pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _0xbd27cf)
    public
    payable
    {
        var _0x1d852d = Acc[msg.sender];
        _0x1d852d.balance += msg.value;
        _0x1d852d._0xacd6b2 = _0xbd27cf>_0xcfca60?_0xbd27cf:_0xcfca60;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x256b3e)
    public
    payable
    {
        var _0x1d852d = Acc[msg.sender];
        if( _0x1d852d.balance>=MinSum && _0x1d852d.balance>=_0x256b3e && _0xcfca60>_0x1d852d._0xacd6b2)
        {
            if(msg.sender.call.value(_0x256b3e)())
            {
                _0x1d852d.balance-=_0x256b3e;
                LogFile.AddMessage(msg.sender,_0x256b3e,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

    struct Holder
    {
        uint _0xacd6b2;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function MY_BANK(address _0x92954e) public{
        LogFile = Log(_0x92954e);
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

    function AddMessage(address _0x6e8897,uint _0x3b1802,string _0xf6526a)
    public
    {
        LastMsg.Sender = _0x6e8897;
        LastMsg.Time = _0xcfca60;
        LastMsg.Val = _0x3b1802;
        LastMsg.Data = _0xf6526a;
        History.push(LastMsg);
    }
}