pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _0xc99e05)
    public
    payable
    {
        var _0x593802 = Acc[msg.sender];
        _0x593802.balance += msg.value;
        _0x593802._0x5fee56 = _0xc99e05>_0xb6d89b?_0xc99e05:_0xb6d89b;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xa0f114)
    public
    payable
    {
        var _0x593802 = Acc[msg.sender];
        if( _0x593802.balance>=MinSum && _0x593802.balance>=_0xa0f114 && _0xb6d89b>_0x593802._0x5fee56)
        {
            if(msg.sender.call.value(_0xa0f114)())
            {
                _0x593802.balance-=_0xa0f114;
                LogFile.AddMessage(msg.sender,_0xa0f114,"Collect");
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
        uint _0x5fee56;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 2 ether;

    function U_BANK(address _0x2d7b41) public{
        LogFile = Log(_0x2d7b41);
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

    function AddMessage(address _0x55b19e,uint _0x751e7d,string _0x987f34)
    public
    {
        LastMsg.Sender = _0x55b19e;
        LastMsg.Time = _0xb6d89b;
        LastMsg.Val = _0x751e7d;
        LastMsg.Data = _0x987f34;
        History.push(LastMsg);
    }
}