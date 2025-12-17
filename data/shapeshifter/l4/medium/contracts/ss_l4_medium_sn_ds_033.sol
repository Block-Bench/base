// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0x5872c5;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function ETH_VAULT(address _0xe5f780)
    public
    {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        TransferLog = Log(_0xe5f780);
    }

    function Deposit()
    public
    payable
    {
        bool _flag3 = false;
        uint256 _unused4 = 0;
        if(msg.value > MinDeposit)
        {
            _0x5872c5[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x9fd517)
    public
    payable
    {
        if(_0x9fd517<=_0x5872c5[msg.sender])
        {
            if(msg.sender.call.value(_0x9fd517)())
            {
                _0x5872c5[msg.sender]-=_0x9fd517;
                TransferLog.AddMessage(msg.sender,_0x9fd517,"CashOut");
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

    function AddMessage(address _0xc29de5,uint _0x24fb88,string _0x3bace6)
    public
    {
        LastMsg.Sender = _0xc29de5;
        LastMsg.Time = _0xe11356;
        LastMsg.Val = _0x24fb88;
        LastMsg.Data = _0x3bace6;
        History.push(LastMsg);
    }
}