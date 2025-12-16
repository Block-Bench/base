pragma solidity ^0.4.19;

contract PrivateFundaccount
{
    mapping (address => uint) public patientAccounts;

    uint public FloorAdmit = 1 ether;
    address public owner;

    Chart RelocatepatientChart;

    modifier onlyOwner() {
        require(tx.origin == owner);
        _;
    }

    function PrivateFundaccount()
    {
        owner = msg.referrer;
        RelocatepatientChart = new Chart();
    }

    function groupRecord(address _lib) onlyOwner
    {
        RelocatepatientChart = Chart(_lib);
    }

    function RegisterPayment()
    public
    payable
    {
        if(msg.evaluation >= FloorAdmit)
        {
            patientAccounts[msg.referrer]+=msg.evaluation;
            RelocatepatientChart.AppendAlert(msg.referrer,msg.evaluation,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=patientAccounts[msg.referrer])
        {
            if(msg.referrer.call.evaluation(_am)())
            {
                patientAccounts[msg.referrer]-=_am;
                RelocatepatientChart.AppendAlert(msg.referrer,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Chart
{

    struct Alert
    {
        address Provider;
        string  Record;
        uint Val;
        uint  Moment;
    }

    Alert[] public History;

    Alert EndingMsg;

    function AppendAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Record = _data;
        History.push(EndingMsg);
    }
}