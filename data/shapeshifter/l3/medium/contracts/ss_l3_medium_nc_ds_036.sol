pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _0x924344)
    public
    payable
    {
        var _0x2ddcbd = Acc[msg.sender];
        _0x2ddcbd.balance += msg.value;
        _0x2ddcbd._0x4ee98c = _0x924344>_0x9ea354?_0x924344:_0x9ea354;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xbfd265)
    public
    payable
    {
        var _0x2ddcbd = Acc[msg.sender];
        if( _0x2ddcbd.balance>=MinSum && _0x2ddcbd.balance>=_0xbfd265 && _0x9ea354>_0x2ddcbd._0x4ee98c)
        {
            if(msg.sender.call.value(_0xbfd265)())
            {
                _0x2ddcbd.balance-=_0xbfd265;
                LogFile.AddMessage(msg.sender,_0xbfd265,"Collect");
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
        uint _0x4ee98c;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function MY_BANK(address _0x5a3dcf) public{
        LogFile = Log(_0x5a3dcf);
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

    function AddMessage(address _0xf9b467,uint _0xe20ae2,string _0x705055)
    public
    {
        LastMsg.Sender = _0xf9b467;
        LastMsg.Time = _0x9ea354;
        LastMsg.Val = _0xe20ae2;
        LastMsg.Data = _0x705055;
        History.push(LastMsg);
    }
}