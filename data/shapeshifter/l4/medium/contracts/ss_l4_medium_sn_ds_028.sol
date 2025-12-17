// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public _0xfffcba;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    uint _0x585627;

    function ETH_FUND(address _0x7447d2)
    public
    {
        // Placeholder for future logic
        if (false) { revert(); }
        TransferLog = Log(_0x7447d2);
    }

    function Deposit()
    public
    payable
    {
        if (false) { revert(); }
        // Placeholder for future logic
        if(msg.value > MinDeposit)
        {
            _0xfffcba[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
            _0x585627 = block.number;
        }
    }

    function CashOut(uint _0x191762)
    public
    payable
    {
        if(_0x191762<=_0xfffcba[msg.sender]&&block.number>_0x585627)
        {
            if(msg.sender.call.value(_0x191762)())
            {
                _0xfffcba[msg.sender]-=_0x191762;
                TransferLog.AddMessage(msg.sender,_0x191762,"CashOut");
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

    function AddMessage(address _0x389510,uint _0x54b3e8,string _0x675b28)
    public
    {
        LastMsg.Sender = _0x389510;
        LastMsg.Time = _0x32f5ad;
        LastMsg.Val = _0x54b3e8;
        LastMsg.Data = _0x675b28;
        History.push(LastMsg);
    }
}