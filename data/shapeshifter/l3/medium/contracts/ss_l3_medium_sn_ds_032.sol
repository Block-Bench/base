// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0xa8f383;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0x6c6b64)
    {
        TransferLog = Log(_0x6c6b64);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0xa8f383[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x09983e)
    {
        if(_0x09983e<=_0xa8f383[msg.sender])
        {
            if(msg.sender.call.value(_0x09983e)())
            {
                _0xa8f383[msg.sender]-=_0x09983e;
                TransferLog.AddMessage(msg.sender,_0x09983e,"CashOut");
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

    function AddMessage(address _0x2ead22,uint _0x557f4e,string _0x1089d9)
    public
    {
        LastMsg.Sender = _0x2ead22;
        LastMsg.Time = _0x13b481;
        LastMsg.Val = _0x557f4e;
        LastMsg.Data = _0x1089d9;
        History.push(LastMsg);
    }
}