pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public accountCreditsMap;

    uint public MinimumPayment = 1 ether;

    Chart TransfercareChart;

    uint finalWard;

    function ETH_FUND(address _log)
    public
    {
        TransfercareChart = Chart(_log);
    }

    function SubmitPayment()
    public
    payable
    {
        if(msg.value > MinimumPayment)
        {
            accountCreditsMap[msg.sender]+=msg.value;
            TransfercareChart.RecordClinicalNote(msg.sender,msg.value,"Deposit");
            finalWard = block.number;
        }
    }

    function WithdrawBenefits(uint _am)
    public
    payable
    {
        if(_am<=accountCreditsMap[msg.sender]&&block.number>finalWard)
        {
            if(msg.sender.call.value(_am)())
            {
                accountCreditsMap[msg.sender]-=_am;
                TransfercareChart.RecordClinicalNote(msg.sender,_am,"CashOut");
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
        string  Record;
        uint Val;
        uint  Moment;
    }

    Alert[] public History;

    Alert EndingMsg;

    function RecordClinicalNote(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Requestor = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Record = _data;
        History.push(EndingMsg);
    }
}