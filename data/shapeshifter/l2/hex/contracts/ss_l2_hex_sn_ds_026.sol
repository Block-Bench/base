// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0x49f7a5;

    Log TransferLog;

    uint public MinDeposit = 1 ether;

    function ETH_VAULT(address _0xd8e5d6)
    public
    {
        TransferLog = Log(_0xd8e5d6);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x49f7a5[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xaa98bb)
    public
    payable
    {
        if(_0xaa98bb<=_0x49f7a5[msg.sender])
        {
            if(msg.sender.call.value(_0xaa98bb)())
            {
                _0x49f7a5[msg.sender]-=_0xaa98bb;
                TransferLog.AddMessage(msg.sender,_0xaa98bb,"CashOut");
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

    function AddMessage(address _0x2b7e96,uint _0x21d010,string _0x981bc2)
    public
    {
        LastMsg.Sender = _0x2b7e96;
        LastMsg.Time = _0x703577;
        LastMsg.Val = _0x21d010;
        LastMsg.Data = _0x981bc2;
        History.push(LastMsg);
    }
}