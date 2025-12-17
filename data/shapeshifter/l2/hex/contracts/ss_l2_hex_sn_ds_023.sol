// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _0xaf1df7)
    public
    payable
    {
        var _0x8c955a = Acc[msg.sender];
        _0x8c955a.balance += msg.value;
        _0x8c955a._0x605ad3 = _0xaf1df7>_0xa3c94c?_0xaf1df7:_0xa3c94c;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x464354)
    public
    payable
    {
        var _0x8c955a = Acc[msg.sender];
        if( _0x8c955a.balance>=MinSum && _0x8c955a.balance>=_0x464354 && _0xa3c94c>_0x8c955a._0x605ad3)
        {
            if(msg.sender.call.value(_0x464354)())
            {
                _0x8c955a.balance-=_0x464354;
                LogFile.AddMessage(msg.sender,_0x464354,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

    struct Holder
    {
        uint _0x605ad3;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 2 ether;

    function U_BANK(address _0x3c4b94) public{
        LogFile = Log(_0x3c4b94);
    }
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

    function AddMessage(address _0xadec94,uint _0xab1542,string _0xc1a990)
    public
    {
        LastMsg.Sender = _0xadec94;
        LastMsg.Time = _0xa3c94c;
        LastMsg.Val = _0xab1542;
        LastMsg.Data = _0xc1a990;
        History.push(LastMsg);
    }
}