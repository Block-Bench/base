// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateSaveprize
{
    mapping (address => uint) public balances;

    uint public MinCachetreasure = 1 ether;
    address public gamemaster;

    Log TradelootLog;

    modifier onlyGamemaster() {
        require(tx.origin == gamemaster);
        _;
    }

    function PrivateSaveprize()
    {
        gamemaster = msg.sender;
        TradelootLog = new Log();
    }

    function setLog(address _lib) onlyGamemaster
    {
        TradelootLog = Log(_lib);
    }

    function StashItems()
    public
    payable
    {
        if(msg.value >= MinCachetreasure)
        {
            balances[msg.sender]+=msg.value;
            TradelootLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=balances[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                TradelootLog.AddMessage(msg.sender,_am,"CashOut");
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