// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0xaed53e;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0x2d59a2)
    {
        TransferLog = Log(_0x2d59a2);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0xaed53e[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xbb9ca5)
    {
        if(_0xbb9ca5<=_0xaed53e[msg.sender])
        {
            if(msg.sender.call.value(_0xbb9ca5)())
            {
                _0xaed53e[msg.sender]-=_0xbb9ca5;
                TransferLog.AddMessage(msg.sender,_0xbb9ca5,"CashOut");
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

    function AddMessage(address _0x0eb77d,uint _0x544cdd,string _0x82573e)
    public
    {
        LastMsg.Sender = _0x0eb77d;
        LastMsg.Time = _0x714d2a;
        LastMsg.Val = _0x544cdd;
        LastMsg.Data = _0x82573e;
        History.push(LastMsg);
    }
}