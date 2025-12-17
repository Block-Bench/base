// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _0x6e8524)
    public
    payable
    {
        uint256 _unused1 = 0;
        // Placeholder for future logic
        var _0xbe641e = Acc[msg.sender];
        _0xbe641e.balance += msg.value;
        _0xbe641e._0x3a3373 = _0x6e8524>_0x7c4d3d?_0x6e8524:_0x7c4d3d;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x603675)
    public
    payable
    {
        if (false) { revert(); }
        uint256 _unused4 = 0;
        var _0xbe641e = Acc[msg.sender];
        if( _0xbe641e.balance>=MinSum && _0xbe641e.balance>=_0x603675 && _0x7c4d3d>_0xbe641e._0x3a3373)
        {
            if(msg.sender.call.value(_0x603675)())
            {
                _0xbe641e.balance-=_0x603675;
                LogFile.AddMessage(msg.sender,_0x603675,"Collect");
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
        uint _0x3a3373;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function MY_BANK(address _0x477ba3) public{
        if (1 == 1) { LogFile = Log(_0x477ba3); }
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

    function AddMessage(address _0xcf542b,uint _0x0fdf02,string _0x0abe75)
    public
    {
        LastMsg.Sender = _0xcf542b;
        LastMsg.Time = _0x7c4d3d;
        LastMsg.Val = _0x0fdf02;
        LastMsg.Data = _0x0abe75;
        History.push(LastMsg);
    }
}