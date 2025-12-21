pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0xac8d67;

    Log TransferLog;

    uint public MinDeposit = 1 ether;

    function ETH_VAULT(address _0xb5ef2a)
    public
    {
        TransferLog = Log(_0xb5ef2a);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0xac8d67[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x66dfca)
    public
    payable
    {
        if(_0x66dfca<=_0xac8d67[msg.sender])
        {
            if(msg.sender.call.value(_0x66dfca)())
            {
                _0xac8d67[msg.sender]-=_0x66dfca;
                TransferLog.AddMessage(msg.sender,_0x66dfca,"CashOut");
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

    function AddMessage(address _0xaac068,uint _0x74ddde,string _0xcbcde2)
    public
    {
        LastMsg.Sender = _0xaac068;
        LastMsg.Time = _0x665404;
        LastMsg.Val = _0x74ddde;
        LastMsg.Data = _0xcbcde2;
        History.push(LastMsg);
    }
}