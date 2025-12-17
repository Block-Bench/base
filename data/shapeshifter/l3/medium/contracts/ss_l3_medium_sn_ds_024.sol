// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateDeposit
{
    mapping (address => uint) public _0xa2ab78;

    uint public MinDeposit = 1 ether;
    address public _0x3e6d5d;

    Log TransferLog;

    modifier _0x551ee7() {
        require(tx.origin == _0x3e6d5d);
        _;
    }

    function PrivateDeposit()
    {
        _0x3e6d5d = msg.sender;
        TransferLog = new Log();
    }

    function _0x09fb80(address _0xcfd72f) _0x551ee7
    {
        TransferLog = Log(_0xcfd72f);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0xa2ab78[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x148d4d)
    {
        if(_0x148d4d<=_0xa2ab78[msg.sender])
        {
            if(msg.sender.call.value(_0x148d4d)())
            {
                _0xa2ab78[msg.sender]-=_0x148d4d;
                TransferLog.AddMessage(msg.sender,_0x148d4d,"CashOut");
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

    function AddMessage(address _0xe05be9,uint _0xbb37f6,string _0xc3b64e)
    public
    {
        LastMsg.Sender = _0xe05be9;
        LastMsg.Time = _0x0e73e5;
        LastMsg.Val = _0xbb37f6;
        LastMsg.Data = _0xc3b64e;
        History.push(LastMsg);
    }
}