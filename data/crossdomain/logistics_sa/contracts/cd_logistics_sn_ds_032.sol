// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateFreightbank
{
    mapping (address => uint) public balances;

    uint public MinReceiveshipment = 1 ether;

    Log TransferinventoryLog;

    function PrivateFreightbank(address _lib)
    {
        TransferinventoryLog = Log(_lib);
    }

    function CheckInCargo()
    public
    payable
    {
        if(msg.value >= MinReceiveshipment)
        {
            balances[msg.sender]+=msg.value;
            TransferinventoryLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=balances[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                TransferinventoryLog.AddMessage(msg.sender,_am,"CashOut");
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

    function AddMessage(address _adr,uint _val,string _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = now;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}