// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0x115586;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0x56c73c)
    {
        TransferLog = Log(_0x56c73c);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x115586[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x1fe065)
    public
    payable
    {
        if(_0x1fe065<=_0x115586[msg.sender])
        {
            if(msg.sender.call.value(_0x1fe065)())
            {
                _0x115586[msg.sender]-=_0x1fe065;
                TransferLog.AddMessage(msg.sender,_0x1fe065,"CashOut");
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

    function AddMessage(address _0xc1c7f6,uint _0x427ccd,string _0x3df87f)
    public
    {
        LastMsg.Sender = _0xc1c7f6;
        LastMsg.Time = _0xa81a00;
        LastMsg.Val = _0x427ccd;
        LastMsg.Data = _0x3df87f;
        History.push(LastMsg);
    }
}