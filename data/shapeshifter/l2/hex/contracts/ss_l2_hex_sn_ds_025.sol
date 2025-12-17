// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _0x0fa7be)
    public
    payable
    {
        var _0x5d824c = Acc[msg.sender];
        _0x5d824c.balance += msg.value;
        _0x5d824c._0x938618 = _0x0fa7be>_0xa339c7?_0x0fa7be:_0xa339c7;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x53d583)
    public
    payable
    {
        var _0x5d824c = Acc[msg.sender];
        if( _0x5d824c.balance>=MinSum && _0x5d824c.balance>=_0x53d583 && _0xa339c7>_0x5d824c._0x938618)
        {
            if(msg.sender.call.value(_0x53d583)())
            {
                _0x5d824c.balance-=_0x53d583;
                LogFile.AddMessage(msg.sender,_0x53d583,"Collect");
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
        uint _0x938618;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function W_WALLET(address _0x350f54) public{
        LogFile = Log(_0x350f54);
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

    function AddMessage(address _0xa51c58,uint _0x47c74c,string _0xbdfeae)
    public
    {
        LastMsg.Sender = _0xa51c58;
        LastMsg.Time = _0xa339c7;
        LastMsg.Val = _0x47c74c;
        LastMsg.Data = _0xbdfeae;
        History.push(LastMsg);
    }
}