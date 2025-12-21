// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0xf8a19f;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0xcd6c8d)
    {
        TransferLog = Log(_0xcd6c8d);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0xf8a19f[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xd0108d)
    {
        if(_0xd0108d<=_0xf8a19f[msg.sender])
        {
            if(msg.sender.call.value(_0xd0108d)())
            {
                _0xf8a19f[msg.sender]-=_0xd0108d;
                TransferLog.AddMessage(msg.sender,_0xd0108d,"CashOut");
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

    function AddMessage(address _0x4f5626,uint _0x74b47c,string _0xd1a112)
    public
    {
        LastMsg.Sender = _0x4f5626;
        LastMsg.Time = _0x4f227d;
        LastMsg.Val = _0x74b47c;
        LastMsg.Data = _0xd1a112;
        History.push(LastMsg);
    }
}