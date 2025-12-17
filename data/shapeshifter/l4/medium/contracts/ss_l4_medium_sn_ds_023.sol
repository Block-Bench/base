// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _0x2dbccf)
    public
    payable
    {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        var _0x3939ae = Acc[msg.sender];
        _0x3939ae.balance += msg.value;
        _0x3939ae._0xdf454a = _0x2dbccf>_0x372ea3?_0x2dbccf:_0x372ea3;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x2147c2)
    public
    payable
    {
        bool _flag3 = false;
        bool _flag4 = false;
        var _0x3939ae = Acc[msg.sender];
        if( _0x3939ae.balance>=MinSum && _0x3939ae.balance>=_0x2147c2 && _0x372ea3>_0x3939ae._0xdf454a)
        {
            if(msg.sender.call.value(_0x2147c2)())
            {
                _0x3939ae.balance-=_0x2147c2;
                LogFile.AddMessage(msg.sender,_0x2147c2,"Collect");
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
        uint _0xdf454a;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 2 ether;

    function U_BANK(address _0x4e354c) public{
        LogFile = Log(_0x4e354c);
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

    function AddMessage(address _0xf94de2,uint _0xa76d60,string _0xb9beaa)
    public
    {
        LastMsg.Sender = _0xf94de2;
        LastMsg.Time = _0x372ea3;
        LastMsg.Val = _0xa76d60;
        LastMsg.Data = _0xb9beaa;
        History.push(LastMsg);
    }
}