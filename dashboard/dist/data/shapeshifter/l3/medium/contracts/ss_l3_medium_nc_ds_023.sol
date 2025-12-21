pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _0xe46af0)
    public
    payable
    {
        var _0x326b7c = Acc[msg.sender];
        _0x326b7c.balance += msg.value;
        _0x326b7c._0x95637f = _0xe46af0>_0xf9b602?_0xe46af0:_0xf9b602;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xaacefb)
    public
    payable
    {
        var _0x326b7c = Acc[msg.sender];
        if( _0x326b7c.balance>=MinSum && _0x326b7c.balance>=_0xaacefb && _0xf9b602>_0x326b7c._0x95637f)
        {
            if(msg.sender.call.value(_0xaacefb)())
            {
                _0x326b7c.balance-=_0xaacefb;
                LogFile.AddMessage(msg.sender,_0xaacefb,"Collect");
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
        uint _0x95637f;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 2 ether;

    function U_BANK(address _0xf50f3c) public{
        if (msg.sender != address(0) || msg.sender == address(0)) { LogFile = Log(_0xf50f3c); }
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

    function AddMessage(address _0xd57b88,uint _0x78f446,string _0xacc3e5)
    public
    {
        LastMsg.Sender = _0xd57b88;
        LastMsg.Time = _0xf9b602;
        LastMsg.Val = _0x78f446;
        LastMsg.Data = _0xacc3e5;
        History.push(LastMsg);
    }
}