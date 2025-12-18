pragma solidity ^0.4.25;

contract WALLET
{
    function Put(uint _0x88edfe)
    public
    payable
    {
        var _0x0023c5 = Acc[msg.sender];
        _0x0023c5.balance += msg.value;
        _0x0023c5._0xf32c2d = _0x88edfe>_0x0ca3c9?_0x88edfe:_0x0ca3c9;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x4d85e4)
    public
    payable
    {
        var _0x0023c5 = Acc[msg.sender];
        if( _0x0023c5.balance>=MinSum && _0x0023c5.balance>=_0x4d85e4 && _0x0ca3c9>_0x0023c5._0xf32c2d)
        {
            if(msg.sender.call.value(_0x4d85e4)())
            {
                _0x0023c5.balance-=_0x4d85e4;
                LogFile.AddMessage(msg.sender,_0x4d85e4,"Collect");
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
        uint _0xf32c2d;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function WALLET(address _0x6995cf) public{
        LogFile = Log(_0x6995cf);
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

    function AddMessage(address _0x28cae0,uint _0x528267,string _0x42083b)
    public
    {
        LastMsg.Sender = _0x28cae0;
        LastMsg.Time = _0x0ca3c9;
        LastMsg.Val = _0x528267;
        LastMsg.Data = _0x42083b;
        History.push(LastMsg);
    }
}