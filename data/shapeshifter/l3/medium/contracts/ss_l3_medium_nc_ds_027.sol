pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _0x416cef)
    public
    payable
    {
        var _0xa7ad08 = Acc[msg.sender];
        _0xa7ad08.balance += msg.value;
        _0xa7ad08._0x485806 = _0x416cef>_0x5b4689?_0x416cef:_0x5b4689;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x7bdd91)
    public
    payable
    {
        var _0xa7ad08 = Acc[msg.sender];
        if( _0xa7ad08.balance>=MinSum && _0xa7ad08.balance>=_0x7bdd91 && _0x5b4689>_0xa7ad08._0x485806)
        {
            if(msg.sender.call.value(_0x7bdd91)())
            {
                _0xa7ad08.balance-=_0x7bdd91;
                LogFile.AddMessage(msg.sender,_0x7bdd91,"Collect");
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
        uint _0x485806;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function X_WALLET(address _0xf716ee) public{
        LogFile = Log(_0xf716ee);
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

    function AddMessage(address _0x925d86,uint _0xdba6d1,string _0xdcd6e4)
    public
    {
        LastMsg.Sender = _0x925d86;
        LastMsg.Time = _0x5b4689;
        LastMsg.Val = _0xdba6d1;
        LastMsg.Data = _0xdcd6e4;
        History.push(LastMsg);
    }
}