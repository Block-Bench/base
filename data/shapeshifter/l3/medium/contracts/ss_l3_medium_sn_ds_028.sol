// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public _0x5594f4;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    uint _0x2d332d;

    function ETH_FUND(address _0xf92d02)
    public
    {
        TransferLog = Log(_0xf92d02);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x5594f4[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
            _0x2d332d = block.number;
        }
    }

    function CashOut(uint _0xa6e1ab)
    public
    payable
    {
        if(_0xa6e1ab<=_0x5594f4[msg.sender]&&block.number>_0x2d332d)
        {
            if(msg.sender.call.value(_0xa6e1ab)())
            {
                _0x5594f4[msg.sender]-=_0xa6e1ab;
                TransferLog.AddMessage(msg.sender,_0xa6e1ab,"CashOut");
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

    function AddMessage(address _0x313665,uint _0xd0aa32,string _0xc24f9c)
    public
    {
        LastMsg.Sender = _0x313665;
        LastMsg.Time = _0x59c962;
        LastMsg.Val = _0xd0aa32;
        LastMsg.Data = _0xc24f9c;
        History.push(LastMsg);
    }
}