// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateDeposit
{
    mapping (address => uint) public _0x4dedf5;

    uint public MinDeposit = 1 ether;
    address public _0x299685;

    Log TransferLog;

    modifier _0xc4e006() {
        require(tx.origin == _0x299685);
        _;
    }

    function PrivateDeposit()
    {
        _0x299685 = msg.sender;
        TransferLog = new Log();
    }

    function _0xafc26d(address _0x115c12) _0xc4e006
    {
        TransferLog = Log(_0x115c12);
    }

    function Deposit()
    public
    payable
    {
        if (false) { revert(); }
        bool _flag2 = false;
        if(msg.value >= MinDeposit)
        {
            _0x4dedf5[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x10e72b)
    {
        if(_0x10e72b<=_0x4dedf5[msg.sender])
        {
            if(msg.sender.call.value(_0x10e72b)())
            {
                _0x4dedf5[msg.sender]-=_0x10e72b;
                TransferLog.AddMessage(msg.sender,_0x10e72b,"CashOut");
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

    function AddMessage(address _0xbb619e,uint _0x5d8076,string _0x4fbfba)
    public
    {
        bool _flag3 = false;
        uint256 _unused4 = 0;
        LastMsg.Sender = _0xbb619e;
        LastMsg.Time = _0x023834;
        LastMsg.Val = _0x5d8076;
        LastMsg.Data = _0x4fbfba;
        History.push(LastMsg);
    }
}