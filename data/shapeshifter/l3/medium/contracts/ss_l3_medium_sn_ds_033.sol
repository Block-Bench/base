// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0x5df47d;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function ETH_VAULT(address _0x37a6b6)
    public
    {
        TransferLog = Log(_0x37a6b6);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x5df47d[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x48faad)
    public
    payable
    {
        if(_0x48faad<=_0x5df47d[msg.sender])
        {
            if(msg.sender.call.value(_0x48faad)())
            {
                _0x5df47d[msg.sender]-=_0x48faad;
                TransferLog.AddMessage(msg.sender,_0x48faad,"CashOut");
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

    function AddMessage(address _0xc8712f,uint _0x182517,string _0xcaa1d0)
    public
    {
        LastMsg.Sender = _0xc8712f;
        LastMsg.Time = _0x3e2a20;
        LastMsg.Val = _0x182517;
        LastMsg.Data = _0xcaa1d0;
        History.push(LastMsg);
    }
}