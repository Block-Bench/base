// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0xebc46d;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0x6f961c)
    {
        TransferLog = Log(_0x6f961c);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0xebc46d[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x33d36c)
    {
        if(_0x33d36c<=_0xebc46d[msg.sender])
        {
            if(msg.sender.call.value(_0x33d36c)())
            {
                _0xebc46d[msg.sender]-=_0x33d36c;
                TransferLog.AddMessage(msg.sender,_0x33d36c,"CashOut");
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

    function AddMessage(address _0x82410d,uint _0x1fdec4,string _0x523840)
    public
    {
        LastMsg.Sender = _0x82410d;
        LastMsg.Time = _0x7f1b68;
        LastMsg.Val = _0x1fdec4;
        LastMsg.Data = _0x523840;
        History.push(LastMsg);
    }
}