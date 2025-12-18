pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public _0x31f9cf;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    uint _0xe48387;

    function ETH_FUND(address _0x4c44e2)
    public
    {
        TransferLog = Log(_0x4c44e2);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x31f9cf[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
            _0xe48387 = block.number;
        }
    }

    function CashOut(uint _0x37a416)
    public
    payable
    {
        if(_0x37a416<=_0x31f9cf[msg.sender]&&block.number>_0xe48387)
        {
            if(msg.sender.call.value(_0x37a416)())
            {
                _0x31f9cf[msg.sender]-=_0x37a416;
                TransferLog.AddMessage(msg.sender,_0x37a416,"CashOut");
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

    function AddMessage(address _0x9247f8,uint _0x6aa7ac,string _0x200eef)
    public
    {
        LastMsg.Sender = _0x9247f8;
        LastMsg.Time = _0x5cef68;
        LastMsg.Val = _0x6aa7ac;
        LastMsg.Data = _0x200eef;
        History.push(LastMsg);
    }
}