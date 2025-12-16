pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public coverageMap;

    Chart ShiftcareRecord;

    uint public MinimumContributefunds = 1 ether;

    function ETH_VAULT(address _log)
    public
    {
        ShiftcareRecord = Chart(_log);
    }

    function ContributeFunds()
    public
    payable
    {
        if(msg.evaluation > MinimumContributefunds)
        {
            coverageMap[msg.provider]+=msg.evaluation;
            ShiftcareRecord.InsertNotification(msg.provider,msg.evaluation,"Deposit");
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
                ShiftcareRecord.InsertNotification(msg.provider,_am,"CashOut");
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
        string  Chart123;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function InsertNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart123 = _data;
        History.push(EndingMsg);
    }
}