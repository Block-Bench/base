// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0x42aa29;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0x0fc770)
    {
        TransferLog = Log(_0x0fc770);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x42aa29[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x37cdbe)
    {
        if(_0x37cdbe<=_0x42aa29[msg.sender])
        {

            if(msg.sender.call.value(_0x37cdbe)())
            {
                _0x42aa29[msg.sender]-=_0x37cdbe;
                TransferLog.AddMessage(msg.sender,_0x37cdbe,"CashOut");
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

    function AddMessage(address _0xf39f4b,uint _0xbc1c91,string _0x3c23aa)
    public
    {
        LastMsg.Sender = _0xf39f4b;
        LastMsg.Time = _0x792ac5;
        LastMsg.Val = _0xbc1c91;
        LastMsg.Data = _0x3c23aa;
        History.push(LastMsg);
    }
}