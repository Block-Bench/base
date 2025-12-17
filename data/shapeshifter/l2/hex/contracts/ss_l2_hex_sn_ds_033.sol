// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0x5bf950;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function ETH_VAULT(address _0x8a55ac)
    public
    {
        TransferLog = Log(_0x8a55ac);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x5bf950[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x353e55)
    public
    payable
    {
        if(_0x353e55<=_0x5bf950[msg.sender])
        {
            if(msg.sender.call.value(_0x353e55)())
            {
                _0x5bf950[msg.sender]-=_0x353e55;
                TransferLog.AddMessage(msg.sender,_0x353e55,"CashOut");
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

    function AddMessage(address _0xb540b3,uint _0x1c34a7,string _0x3d5bde)
    public
    {
        LastMsg.Sender = _0xb540b3;
        LastMsg.Time = _0x23bfef;
        LastMsg.Val = _0x1c34a7;
        LastMsg.Data = _0x3d5bde;
        History.push(LastMsg);
    }
}