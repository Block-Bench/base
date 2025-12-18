// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateDeposit
{
    mapping (address => uint) public _0x3da453;

    uint public MinDeposit = 1 ether;
    address public _0xe62c31;

    Log TransferLog;

    modifier _0x08a473() {
        require(tx.origin == _0xe62c31);
        _;
    }

    function PrivateDeposit()
    {
        _0xe62c31 = msg.sender;
        TransferLog = new Log();
    }

    function _0x432e3b(address _0xb9e12f) _0x08a473
    {
        TransferLog = Log(_0xb9e12f);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x3da453[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x36e8aa)
    {
        if(_0x36e8aa<=_0x3da453[msg.sender])
        {
            if(msg.sender.call.value(_0x36e8aa)())
            {
                _0x3da453[msg.sender]-=_0x36e8aa;
                TransferLog.AddMessage(msg.sender,_0x36e8aa,"CashOut");
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

    function AddMessage(address _0x2135fd,uint _0x70aa63,string _0x8bd61e)
    public
    {
        LastMsg.Sender = _0x2135fd;
        LastMsg.Time = _0x3cd64f;
        LastMsg.Val = _0x70aa63;
        LastMsg.Data = _0x8bd61e;
        History.push(LastMsg);
    }
}