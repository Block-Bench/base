// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public benefitsRecord;

    uint public MinimumAdmit = 1 ether;

    Record PasscaseRecord;

    function PrivateBank(address _lib)
    {
        PasscaseRecord = Record(_lib);
    }

    function SubmitPayment()
    public
    payable
    {
        if(msg.assessment >= MinimumAdmit)
        {
            benefitsRecord[msg.provider]+=msg.assessment;
            PasscaseRecord.AppendNotification(msg.provider,msg.assessment,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=benefitsRecord[msg.provider])
        {
            if(msg.provider.call.assessment(_am)())
            {
                benefitsRecord[msg.provider]-=_am;
                PasscaseRecord.AppendNotification(msg.provider,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Notification
    {
        address Referrer;
        string  Chart;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification FinalMsg;

    function AppendNotification(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Referrer = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Chart = _data;
        History.push(FinalMsg);
    }
}