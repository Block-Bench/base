// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0x2c7ecd;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0x7c1ef7)
    {
        TransferLog = Log(_0x7c1ef7);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x2c7ecd[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x8aeb41)
    {
        if(_0x8aeb41<=_0x2c7ecd[msg.sender])
        {
            if(msg.sender.call.value(_0x8aeb41)())
            {
                _0x2c7ecd[msg.sender]-=_0x8aeb41;
                TransferLog.AddMessage(msg.sender,_0x8aeb41,"CashOut");
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

    function AddMessage(address _0x453c49,uint _0x6d557b,string _0x373ca6)
    public
    {
        LastMsg.Sender = _0x453c49;
        LastMsg.Time = _0x69cc19;
        LastMsg.Val = _0x6d557b;
        LastMsg.Data = _0x373ca6;
        History.push(LastMsg);
    }
}