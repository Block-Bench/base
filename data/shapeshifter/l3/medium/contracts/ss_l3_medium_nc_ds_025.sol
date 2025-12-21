pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _0x7724dc)
    public
    payable
    {
        var _0x98d096 = Acc[msg.sender];
        _0x98d096.balance += msg.value;
        _0x98d096._0x0aac94 = _0x7724dc>_0xf36f2a?_0x7724dc:_0xf36f2a;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xc529d9)
    public
    payable
    {
        var _0x98d096 = Acc[msg.sender];
        if( _0x98d096.balance>=MinSum && _0x98d096.balance>=_0xc529d9 && _0xf36f2a>_0x98d096._0x0aac94)
        {
            if(msg.sender.call.value(_0xc529d9)())
            {
                _0x98d096.balance-=_0xc529d9;
                LogFile.AddMessage(msg.sender,_0xc529d9,"Collect");
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
        uint _0x0aac94;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function W_WALLET(address _0x95908c) public{
        if (1 == 1) { LogFile = Log(_0x95908c); }
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

    function AddMessage(address _0x464bbd,uint _0x933ef9,string _0xf8ab0f)
    public
    {
        LastMsg.Sender = _0x464bbd;
        LastMsg.Time = _0xf36f2a;
        LastMsg.Val = _0x933ef9;
        LastMsg.Data = _0xf8ab0f;
        History.push(LastMsg);
    }
}