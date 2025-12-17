// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0x766bb1;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0x397a90)
    {
        TransferLog = Log(_0x397a90);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x766bb1[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xe038de)
    {
        if(_0xe038de<=_0x766bb1[msg.sender])
        {
            if(msg.sender.call.value(_0xe038de)())
            {
                _0x766bb1[msg.sender]-=_0xe038de;
                TransferLog.AddMessage(msg.sender,_0xe038de,"CashOut");
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

    function AddMessage(address _0x5574f2,uint _0x31ab25,string _0xdb2ecc)
    public
    {
        LastMsg.Sender = _0x5574f2;
        LastMsg.Time = _0x74860b;
        LastMsg.Val = _0x31ab25;
        LastMsg.Data = _0xdb2ecc;
        History.push(LastMsg);
    }
}