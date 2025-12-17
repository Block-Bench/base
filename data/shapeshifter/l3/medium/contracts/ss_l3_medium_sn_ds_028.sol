// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public _0xd4aded;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    uint _0xf28414;

    function ETH_FUND(address _0xb7b49a)
    public
    {
        TransferLog = Log(_0xb7b49a);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0xd4aded[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
            _0xf28414 = block.number;
        }
    }

    function CashOut(uint _0x086fd1)
    public
    payable
    {
        if(_0x086fd1<=_0xd4aded[msg.sender]&&block.number>_0xf28414)
        {
            if(msg.sender.call.value(_0x086fd1)())
            {
                _0xd4aded[msg.sender]-=_0x086fd1;
                TransferLog.AddMessage(msg.sender,_0x086fd1,"CashOut");
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

    function AddMessage(address _0x041d23,uint _0x6b9973,string _0x6ee1f6)
    public
    {
        LastMsg.Sender = _0x041d23;
        LastMsg.Time = _0x9e20d3;
        LastMsg.Val = _0x6b9973;
        LastMsg.Data = _0x6ee1f6;
        History.push(LastMsg);
    }
}