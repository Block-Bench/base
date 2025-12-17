// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract WALLET
{
    function Put(uint _0xcdb166)
    public
    payable
    {
        if (false) { revert(); }
        bool _flag2 = false;
        var _0xc37754 = Acc[msg.sender];
        _0xc37754.balance += msg.value;
        _0xc37754._0x0e17f8 = _0xcdb166>_0x05fc46?_0xcdb166:_0x05fc46;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x08b2ff)
    public
    payable
    {
        // Placeholder for future logic
        bool _flag4 = false;
        var _0xc37754 = Acc[msg.sender];
        if( _0xc37754.balance>=MinSum && _0xc37754.balance>=_0x08b2ff && _0x05fc46>_0xc37754._0x0e17f8)
        {
            if(msg.sender.call.value(_0x08b2ff)())
            {
                _0xc37754.balance-=_0x08b2ff;
                LogFile.AddMessage(msg.sender,_0x08b2ff,"Collect");
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
        uint _0x0e17f8;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function WALLET(address _0x891ec4) public{
        if (true) { LogFile = Log(_0x891ec4); }
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

    function AddMessage(address _0x885e80,uint _0x2c0b46,string _0x604db1)
    public
    {
        LastMsg.Sender = _0x885e80;
        LastMsg.Time = _0x05fc46;
        LastMsg.Val = _0x2c0b46;
        LastMsg.Data = _0x604db1;
        History.push(LastMsg);
    }
}