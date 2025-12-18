pragma solidity ^0.4.19;

contract PrivateSubmitpayment
{
    mapping (address => uint) public accountCreditsMap;

    uint public MinimumPayment = 1 ether;
    address public owner;

    Record TransfercareRecord;

    modifier onlyOwner() {
        require(tx.origin == owner);
        _;
    }

    function PrivateSubmitpayment()
    {
        owner = msg.sender;
        TransfercareRecord = new Record();
    }

    function groupChart(address _lib) onlyOwner
    {
        TransfercareRecord = Record(_lib);
    }

    function SubmitPayment()
    public
    payable
    {
        if(msg.value >= MinimumPayment)
        {
            accountCreditsMap[msg.sender]+=msg.value;
            TransfercareRecord.RecordClinicalNote(msg.sender,msg.value,"Deposit");
        }
    }

    function WithdrawBenefits(uint _am)
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

contract Record
{

    struct Notification
    {
        address Requestor;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification FinalMsg;

    function RecordClinicalNote(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Requestor = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}