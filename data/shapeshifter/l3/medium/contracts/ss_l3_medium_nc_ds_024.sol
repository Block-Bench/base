pragma solidity ^0.4.19;

contract PrivateDeposit
{
    mapping (address => uint) public _0x9d396e;

    uint public MinDeposit = 1 ether;
    address public _0xafefbc;

    Log TransferLog;

    modifier _0xec6c45() {
        require(tx.origin == _0xafefbc);
        _;
    }

    function PrivateDeposit()
    {
        _0xafefbc = msg.sender;
        TransferLog = new Log();
    }

    function _0xd597ee(address _0xbd6539) _0xec6c45
    {
        TransferLog = Log(_0xbd6539);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x9d396e[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xb5b9cf)
    {
        if(_0xb5b9cf<=_0x9d396e[msg.sender])
        {
            if(msg.sender.call.value(_0xb5b9cf)())
            {
                _0x9d396e[msg.sender]-=_0xb5b9cf;
                TransferLog.AddMessage(msg.sender,_0xb5b9cf,"CashOut");
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

    function AddMessage(address _0xdd52d6,uint _0x7d0f67,string _0x768e9d)
    public
    {
        LastMsg.Sender = _0xdd52d6;
        LastMsg.Time = _0xd06400;
        LastMsg.Val = _0x7d0f67;
        LastMsg.Data = _0x768e9d;
        History.push(LastMsg);
    }
}