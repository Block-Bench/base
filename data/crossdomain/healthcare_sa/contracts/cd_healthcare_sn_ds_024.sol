// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivatePaypremium
{
    mapping (address => uint) public balances;

    uint public MinFundaccount = 1 ether;
    address public administrator;

    Log SharebenefitLog;

    modifier onlyAdministrator() {
        require(tx.origin == administrator);
        _;
    }

    function PrivatePaypremium()
    {
        administrator = msg.sender;
        SharebenefitLog = new Log();
    }

    function setLog(address _lib) onlyAdministrator
    {
        SharebenefitLog = Log(_lib);
    }

    function DepositBenefit()
    public
    payable
    {
        if(msg.value >= MinFundaccount)
        {
            balances[msg.sender]+=msg.value;
            SharebenefitLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=balances[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                SharebenefitLog.AddMessage(msg.sender,_am,"CashOut");
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