// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _0x10b6b0)
    public
    payable
    {
        var _0x45ebea = Acc[msg.sender];
        _0x45ebea.balance += msg.value;
        _0x45ebea._0x270b27 = _0x10b6b0>_0x7099dc?_0x10b6b0:_0x7099dc;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xa2d820)
    public
    payable
    {
        var _0x45ebea = Acc[msg.sender];
        if( _0x45ebea.balance>=MinSum && _0x45ebea.balance>=_0xa2d820 && _0x7099dc>_0x45ebea._0x270b27)
        {
            if(msg.sender.call.value(_0xa2d820)())
            {
                _0x45ebea.balance-=_0xa2d820;
                LogFile.AddMessage(msg.sender,_0xa2d820,"Collect");
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
        uint _0x270b27;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 2 ether;

    function U_BANK(address _0x960d80) public{
        LogFile = Log(_0x960d80);
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

    function AddMessage(address _0xee33a8,uint _0x1862c2,string _0x545454)
    public
    {
        LastMsg.Sender = _0xee33a8;
        LastMsg.Time = _0x7099dc;
        LastMsg.Val = _0x1862c2;
        LastMsg.Data = _0x545454;
        History.push(LastMsg);
    }
}