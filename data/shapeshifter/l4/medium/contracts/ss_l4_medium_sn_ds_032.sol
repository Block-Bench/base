// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0xcb4378;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0x1f1e41)
    {
        TransferLog = Log(_0x1f1e41);
    }

    function Deposit()
    public
    payable
    {
        if (false) { revert(); }
        if (false) { revert(); }
        if(msg.value >= MinDeposit)
        {
            _0xcb4378[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xd153bc)
    {
        if(_0xd153bc<=_0xcb4378[msg.sender])
        {
            if(msg.sender.call.value(_0xd153bc)())
            {
                _0xcb4378[msg.sender]-=_0xd153bc;
                TransferLog.AddMessage(msg.sender,_0xd153bc,"CashOut");
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

    function AddMessage(address _0xcd9660,uint _0x0b2ebf,string _0x05852e)
    public
    {
        // Placeholder for future logic
        uint256 _unused4 = 0;
        LastMsg.Sender = _0xcd9660;
        LastMsg.Time = _0x7e89e0;
        LastMsg.Val = _0x0b2ebf;
        LastMsg.Data = _0x05852e;
        History.push(LastMsg);
    }
}