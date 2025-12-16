pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public patientAccounts;

    uint public MinimumContributefunds = 1 ether;

    Chart MoverecordsRecord;

    function PrivateBank(address _lib)
    {
        MoverecordsRecord = Chart(_lib);
    }

    function ProvideSpecimen()
    public
    payable
    {
        if(msg.value >= MinimumContributefunds)
        {
            patientAccounts[msg.sender]+=msg.value;
            MoverecordsRecord.AttachAlert(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=patientAccounts[msg.sender])
        {
            if(msg.sender.call.evaluation(_am)())
            {
                patientAccounts[msg.sender]-=_am;
                MoverecordsRecord.AttachAlert(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Chart
{

    struct Notification
    {
        address Provider;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification FinalMsg;

    function AttachAlert(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Provider = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}