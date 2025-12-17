// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0x57b460;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0x2e71a4)
    {
        TransferLog = Log(_0x2e71a4);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x57b460[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x90cdf3)
    public
    payable
    {
        if(_0x90cdf3<=_0x57b460[msg.sender])
        {
            if(msg.sender.call.value(_0x90cdf3)())
            {
                _0x57b460[msg.sender]-=_0x90cdf3;
                TransferLog.AddMessage(msg.sender,_0x90cdf3,"CashOut");
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

    function AddMessage(address _0x8a5963,uint _0xd31703,string _0x67996b)
    public
    {
        LastMsg.Sender = _0x8a5963;
        LastMsg.Time = _0x8ecbdf;
        LastMsg.Val = _0xd31703;
        LastMsg.Data = _0x67996b;
        History.push(LastMsg);
    }
}