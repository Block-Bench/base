// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _0x31100c)
    public
    payable
    {
        var _0xa29338 = Acc[msg.sender];
        _0xa29338.balance += msg.value;
        _0xa29338._0x04497f = _0x31100c>_0xbde234?_0x31100c:_0xbde234;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x7e07c6)
    public
    payable
    {
        var _0xa29338 = Acc[msg.sender];
        if( _0xa29338.balance>=MinSum && _0xa29338.balance>=_0x7e07c6 && _0xbde234>_0xa29338._0x04497f)
        {
            if(msg.sender.call.value(_0x7e07c6)())
            {
                _0xa29338.balance-=_0x7e07c6;
                LogFile.AddMessage(msg.sender,_0x7e07c6,"Collect");
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
        uint _0x04497f;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function MY_BANK(address _0xdab231) public{
        LogFile = Log(_0xdab231);
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

    function AddMessage(address _0x8e2cac,uint _0xc6fca2,string _0x7de604)
    public
    {
        LastMsg.Sender = _0x8e2cac;
        LastMsg.Time = _0xbde234;
        LastMsg.Val = _0xc6fca2;
        LastMsg.Data = _0x7de604;
        History.push(LastMsg);
    }
}