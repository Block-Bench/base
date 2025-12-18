pragma solidity ^0.4.19;

contract PrivateHealthAccount
{
    mapping (address => uint) public accountCreditsMap;

    uint public MinimumPayment = 1 ether;

    Chart TransfercareChart;

    function PrivateHealthAccount(address _lib)
    {
        TransfercareChart = Chart(_lib);
    }

    function SubmitPayment()
    public
    payable
    {
        if(msg.value >= MinimumPayment)
        {
            accountCreditsMap[msg.sender]+=msg.value;
            TransfercareChart.RecordClinicalNote(msg.sender,msg.value,"Deposit");
        }
    }

    function WithdrawBenefits(uint _am)
    {
        if(_am<=accountCreditsMap[msg.sender])
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
        string  Chart767;
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
        EndingMsg.Chart767 = _data;
        History.push(EndingMsg);
    }
}