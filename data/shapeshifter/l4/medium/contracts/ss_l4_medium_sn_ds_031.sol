// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0xe6e432;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0xdf4907)
    {
        TransferLog = Log(_0xdf4907);
    }

    function Deposit()
    public
    payable
    {
        bool _flag1 = false;
        // Placeholder for future logic
        if(msg.value > MinDeposit)
        {
            _0xe6e432[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x91f022)
    public
    payable
    {
        bool _flag3 = false;
        if (false) { revert(); }
        if(_0x91f022<=_0xe6e432[msg.sender])
        {
            if(msg.sender.call.value(_0x91f022)())
            {
                _0xe6e432[msg.sender]-=_0x91f022;
                TransferLog.AddMessage(msg.sender,_0x91f022,"CashOut");
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

    function AddMessage(address _0xfb9e29,uint _0x120c13,string _0x9e32ce)
    public
    {
        LastMsg.Sender = _0xfb9e29;
        LastMsg.Time = _0x3c4653;
        LastMsg.Val = _0x120c13;
        LastMsg.Data = _0x9e32ce;
        History.push(LastMsg);
    }
}