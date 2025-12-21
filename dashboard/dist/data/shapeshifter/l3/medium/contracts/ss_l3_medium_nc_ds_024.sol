pragma solidity ^0.4.19;

contract PrivateDeposit
{
    mapping (address => uint) public _0xb978e4;

    uint public MinDeposit = 1 ether;
    address public _0x9e86ce;

    Log TransferLog;

    modifier _0xa41f3f() {
        require(tx.origin == _0x9e86ce);
        _;
    }

    function PrivateDeposit()
    {
        _0x9e86ce = msg.sender;
        TransferLog = new Log();
    }

    function _0x0c6b99(address _0x3408e2) _0xa41f3f
    {
        TransferLog = Log(_0x3408e2);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0xb978e4[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x39ebd6)
    {
        if(_0x39ebd6<=_0xb978e4[msg.sender])
        {
            if(msg.sender.call.value(_0x39ebd6)())
            {
                _0xb978e4[msg.sender]-=_0x39ebd6;
                TransferLog.AddMessage(msg.sender,_0x39ebd6,"CashOut");
            }
        }
    }

    function() public payable{}

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

    function AddMessage(address _0xac040f,uint _0x90afd2,string _0x0ff0f4)
    public
    {
        LastMsg.Sender = _0xac040f;
        LastMsg.Time = _0x588146;
        LastMsg.Val = _0x90afd2;
        LastMsg.Data = _0x0ff0f4;
        History.push(LastMsg);
    }
}