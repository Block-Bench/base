pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public _0x5bb1ce;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    uint _0xab793a;

    function ETH_FUND(address _0xdf903e)
    public
    {
        TransferLog = Log(_0xdf903e);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x5bb1ce[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
            _0xab793a = block.number;
        }
    }

    function CashOut(uint _0x1cbffd)
    public
    payable
    {
        if(_0x1cbffd<=_0x5bb1ce[msg.sender]&&block.number>_0xab793a)
        {
            if(msg.sender.call.value(_0x1cbffd)())
            {
                _0x5bb1ce[msg.sender]-=_0x1cbffd;
                TransferLog.AddMessage(msg.sender,_0x1cbffd,"CashOut");
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

    function AddMessage(address _0xc163bd,uint _0x42d639,string _0x75a8ff)
    public
    {
        LastMsg.Sender = _0xc163bd;
        LastMsg.Time = _0x3223bd;
        LastMsg.Val = _0x42d639;
        LastMsg.Data = _0x75a8ff;
        History.push(LastMsg);
    }
}