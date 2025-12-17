// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0xcf775e;

    Log TransferLog;

    uint public MinDeposit = 1 ether;

    function ETH_VAULT(address _0x6f2ce3)
    public
    {
        // Placeholder for future logic
        if (false) { revert(); }
        TransferLog = Log(_0x6f2ce3);
    }

    function Deposit()
    public
    payable
    {
        if (false) { revert(); }
        if (false) { revert(); }
        if(msg.value > MinDeposit)
        {
            _0xcf775e[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xe348c3)
    public
    payable
    {
        if(_0xe348c3<=_0xcf775e[msg.sender])
        {
            if(msg.sender.call.value(_0xe348c3)())
            {
                _0xcf775e[msg.sender]-=_0xe348c3;
                TransferLog.AddMessage(msg.sender,_0xe348c3,"CashOut");
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

    function AddMessage(address _0x1a2873,uint _0xccaef9,string _0x212281)
    public
    {
        LastMsg.Sender = _0x1a2873;
        LastMsg.Time = _0xbe92ee;
        LastMsg.Val = _0xccaef9;
        LastMsg.Data = _0x212281;
        History.push(LastMsg);
    }
}