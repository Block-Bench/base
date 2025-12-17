// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0x40f362;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0xacf985)
    {
        TransferLog = Log(_0xacf985);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x40f362[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x1013b1)
    {
        if(_0x1013b1<=_0x40f362[msg.sender])
        {

            if(msg.sender.call.value(_0x1013b1)())
            {
                _0x40f362[msg.sender]-=_0x1013b1;
                TransferLog.AddMessage(msg.sender,_0x1013b1,"CashOut");
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

    function AddMessage(address _0xd2439d,uint _0xf2be88,string _0x73086b)
    public
    {
        LastMsg.Sender = _0xd2439d;
        LastMsg.Time = _0xf9f8d2;
        LastMsg.Val = _0xf2be88;
        LastMsg.Data = _0x73086b;
        History.push(LastMsg);
    }
}