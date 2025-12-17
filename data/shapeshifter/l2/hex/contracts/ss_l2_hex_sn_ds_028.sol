// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public _0xc3dc6a;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    uint _0x6534c1;

    function ETH_FUND(address _0x99df3e)
    public
    {
        TransferLog = Log(_0x99df3e);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0xc3dc6a[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
            _0x6534c1 = block.number;
        }
    }

    function CashOut(uint _0x98ae76)
    public
    payable
    {
        if(_0x98ae76<=_0xc3dc6a[msg.sender]&&block.number>_0x6534c1)
        {
            if(msg.sender.call.value(_0x98ae76)())
            {
                _0xc3dc6a[msg.sender]-=_0x98ae76;
                TransferLog.AddMessage(msg.sender,_0x98ae76,"CashOut");
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

    function AddMessage(address _0xfd3da9,uint _0xa200ee,string _0x715029)
    public
    {
        LastMsg.Sender = _0xfd3da9;
        LastMsg.Time = _0xef7014;
        LastMsg.Val = _0xa200ee;
        LastMsg.Data = _0x715029;
        History.push(LastMsg);
    }
}