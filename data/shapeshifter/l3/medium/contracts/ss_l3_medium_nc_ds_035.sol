pragma solidity ^0.4.25;

contract WALLET
{
    function Put(uint _0x32a51d)
    public
    payable
    {
        var _0xeb2b10 = Acc[msg.sender];
        _0xeb2b10.balance += msg.value;
        _0xeb2b10._0x8a4d24 = _0x32a51d>_0x1f0de6?_0x32a51d:_0x1f0de6;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xcfc0c8)
    public
    payable
    {
        var _0xeb2b10 = Acc[msg.sender];
        if( _0xeb2b10.balance>=MinSum && _0xeb2b10.balance>=_0xcfc0c8 && _0x1f0de6>_0xeb2b10._0x8a4d24)
        {
            if(msg.sender.call.value(_0xcfc0c8)())
            {
                _0xeb2b10.balance-=_0xcfc0c8;
                LogFile.AddMessage(msg.sender,_0xcfc0c8,"Collect");
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
        uint _0x8a4d24;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function WALLET(address _0x3943d6) public{
        LogFile = Log(_0x3943d6);
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

    function AddMessage(address _0x155590,uint _0x2691ed,string _0x7c7056)
    public
    {
        LastMsg.Sender = _0x155590;
        LastMsg.Time = _0x1f0de6;
        LastMsg.Val = _0x2691ed;
        LastMsg.Data = _0x7c7056;
        History.push(LastMsg);
    }
}