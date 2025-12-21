// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0xff0797;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0x8f1c98)
    {
        TransferLog = Log(_0x8f1c98);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0xff0797[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xbc0374)
    {
        if(_0xbc0374<=_0xff0797[msg.sender])
        {

            if(msg.sender.call.value(_0xbc0374)())
            {
                _0xff0797[msg.sender]-=_0xbc0374;
                TransferLog.AddMessage(msg.sender,_0xbc0374,"CashOut");
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

    function AddMessage(address _0xddb4b8,uint _0x75f362,string _0x500cce)
    public
    {
        LastMsg.Sender = _0xddb4b8;
        LastMsg.Time = _0xc6e8f3;
        LastMsg.Val = _0x75f362;
        LastMsg.Data = _0x500cce;
        History.push(LastMsg);
    }
}