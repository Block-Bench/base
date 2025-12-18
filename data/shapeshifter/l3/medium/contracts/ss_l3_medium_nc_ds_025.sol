pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _0xf0ae91)
    public
    payable
    {
        var _0x6c5f9c = Acc[msg.sender];
        _0x6c5f9c.balance += msg.value;
        _0x6c5f9c._0x3ea262 = _0xf0ae91>_0xc42533?_0xf0ae91:_0xc42533;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xc43d34)
    public
    payable
    {
        var _0x6c5f9c = Acc[msg.sender];
        if( _0x6c5f9c.balance>=MinSum && _0x6c5f9c.balance>=_0xc43d34 && _0xc42533>_0x6c5f9c._0x3ea262)
        {
            if(msg.sender.call.value(_0xc43d34)())
            {
                _0x6c5f9c.balance-=_0xc43d34;
                LogFile.AddMessage(msg.sender,_0xc43d34,"Collect");
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
        uint _0x3ea262;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function W_WALLET(address _0x1f6faa) public{
        LogFile = Log(_0x1f6faa);
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

    function AddMessage(address _0x031869,uint _0xf25ec1,string _0x533590)
    public
    {
        LastMsg.Sender = _0x031869;
        LastMsg.Time = _0xc42533;
        LastMsg.Val = _0xf25ec1;
        LastMsg.Data = _0x533590;
        History.push(LastMsg);
    }
}