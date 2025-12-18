pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _0x744c75)
    public
    payable
    {
        var _0x03468e = Acc[msg.sender];
        _0x03468e.balance += msg.value;
        _0x03468e._0xabd6b9 = _0x744c75>_0x4d8868?_0x744c75:_0x4d8868;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xbb28ec)
    public
    payable
    {
        var _0x03468e = Acc[msg.sender];
        if( _0x03468e.balance>=MinSum && _0x03468e.balance>=_0xbb28ec && _0x4d8868>_0x03468e._0xabd6b9)
        {
            if(msg.sender.call.value(_0xbb28ec)())
            {
                _0x03468e.balance-=_0xbb28ec;
                LogFile.AddMessage(msg.sender,_0xbb28ec,"Collect");
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
        uint _0xabd6b9;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function X_WALLET(address _0x8b6f6f) public{
        if (true) { LogFile = Log(_0x8b6f6f); }
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

    function AddMessage(address _0x9f48c9,uint _0xc0f0c5,string _0x722912)
    public
    {
        LastMsg.Sender = _0x9f48c9;
        LastMsg.Time = _0x4d8868;
        LastMsg.Val = _0xc0f0c5;
        LastMsg.Data = _0x722912;
        History.push(LastMsg);
    }
}