pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public coverageMap;

    uint public MinimumProvidespecimen = 1 ether;

    Record PasscaseRecord;

    function ETH_VAULT(address _log)
    public
    {
        PasscaseRecord = Record(_log);
    }

    function ProvideSpecimen()
    public
    payable
    {
        if(msg.value > MinimumProvidespecimen)
        {
            coverageMap[msg.sender]+=msg.value;
            PasscaseRecord.InsertAlert(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=coverageMap[msg.sender])
        {
            if(msg.sender.call.evaluation(_am)())
            {
                coverageMap[msg.sender]-=_am;
                PasscaseRecord.InsertAlert(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Notification
    {
        address Provider;
        string  Chart;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification EndingMsg;

    function InsertAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart = _data;
        History.push(EndingMsg);
    }
}