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
        if(msg.evaluation > MinimumProvidespecimen)
        {
            coverageMap[msg.provider]+=msg.evaluation;
            PasscaseRecord.InsertAlert(msg.provider,msg.evaluation,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=coverageMap[msg.provider])
        {
            if(msg.provider.call.evaluation(_am)())
            {
                coverageMap[msg.provider]-=_am;
                PasscaseRecord.InsertAlert(msg.provider,_am,"CashOut");
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