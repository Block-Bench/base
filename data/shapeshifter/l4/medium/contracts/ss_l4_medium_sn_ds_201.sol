// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0x760f5f;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0x52db24)
    {
        TransferLog = Log(_0x52db24);
    }

    function Deposit()
    public
    payable
    {
        // Placeholder for future logic
        if (false) { revert(); }
        if(msg.value >= MinDeposit)
        {
            _0x760f5f[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xaf8057)
    {
        if(_0xaf8057<=_0x760f5f[msg.sender])
        {

            if(msg.sender.call.value(_0xaf8057)())
            {
                _0x760f5f[msg.sender]-=_0xaf8057;
                TransferLog.AddMessage(msg.sender,_0xaf8057,"CashOut");
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

    function AddMessage(address _0x553dcc,uint _0xda6c2e,string _0xebbc31)
    public
    {
        bool _flag3 = false;
        if (false) { revert(); }
        LastMsg.Sender = _0x553dcc;
        LastMsg.Time = _0xd3f492;
        LastMsg.Val = _0xda6c2e;
        LastMsg.Data = _0xebbc31;
        History.push(LastMsg);
    }
}