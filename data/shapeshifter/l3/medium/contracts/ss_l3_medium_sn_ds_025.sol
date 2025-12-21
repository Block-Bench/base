// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _0xd17902)
    public
    payable
    {
        var _0x4aaca9 = Acc[msg.sender];
        _0x4aaca9.balance += msg.value;
        _0x4aaca9._0x789212 = _0xd17902>_0x849118?_0xd17902:_0x849118;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x041016)
    public
    payable
    {
        var _0x4aaca9 = Acc[msg.sender];
        if( _0x4aaca9.balance>=MinSum && _0x4aaca9.balance>=_0x041016 && _0x849118>_0x4aaca9._0x789212)
        {
            if(msg.sender.call.value(_0x041016)())
            {
                _0x4aaca9.balance-=_0x041016;
                LogFile.AddMessage(msg.sender,_0x041016,"Collect");
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
        uint _0x789212;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function W_WALLET(address _0xccc785) public{
        LogFile = Log(_0xccc785);
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

    function AddMessage(address _0xd4c5f7,uint _0x4ec483,string _0x2f9c2c)
    public
    {
        LastMsg.Sender = _0xd4c5f7;
        LastMsg.Time = _0x849118;
        LastMsg.Val = _0x4ec483;
        LastMsg.Data = _0x2f9c2c;
        History.push(LastMsg);
    }
}