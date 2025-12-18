// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0x140d65;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0x350f28)
    {
        TransferLog = Log(_0x350f28);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x140d65[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xce7650)
    public
    payable
    {
        if(_0xce7650<=_0x140d65[msg.sender])
        {
            if(msg.sender.call.value(_0xce7650)())
            {
                _0x140d65[msg.sender]-=_0xce7650;
                TransferLog.AddMessage(msg.sender,_0xce7650,"CashOut");
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

    function AddMessage(address _0xaedefe,uint _0xfd286d,string _0xa32a7f)
    public
    {
        LastMsg.Sender = _0xaedefe;
        LastMsg.Time = _0x102f68;
        LastMsg.Val = _0xfd286d;
        LastMsg.Data = _0xa32a7f;
        History.push(LastMsg);
    }
}