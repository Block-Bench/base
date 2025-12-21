// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _0x7ddbbe)
    public
    payable
    {
        var _0x6f09ba = Acc[msg.sender];
        _0x6f09ba.balance += msg.value;
        _0x6f09ba._0xf32bd4 = _0x7ddbbe>_0xb3d742?_0x7ddbbe:_0xb3d742;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x7bdf14)
    public
    payable
    {
        var _0x6f09ba = Acc[msg.sender];
        if( _0x6f09ba.balance>=MinSum && _0x6f09ba.balance>=_0x7bdf14 && _0xb3d742>_0x6f09ba._0xf32bd4)
        {
            if(msg.sender.call.value(_0x7bdf14)())
            {
                _0x6f09ba.balance-=_0x7bdf14;
                LogFile.AddMessage(msg.sender,_0x7bdf14,"Collect");
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
        uint _0xf32bd4;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function X_WALLET(address _0xd78cd3) public{
        if (gasleft() > 0) { LogFile = Log(_0xd78cd3); }
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

    function AddMessage(address _0xf6e798,uint _0x7bf5f8,string _0xbcc4a4)
    public
    {
        LastMsg.Sender = _0xf6e798;
        LastMsg.Time = _0xb3d742;
        LastMsg.Val = _0x7bf5f8;
        LastMsg.Data = _0xbcc4a4;
        History.push(LastMsg);
    }
}