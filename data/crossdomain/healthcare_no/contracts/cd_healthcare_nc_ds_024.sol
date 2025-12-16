pragma solidity ^0.4.19;

contract PrivatePaypremium
{
    mapping (address => uint) public balances;

    uint public MinContributepremium = 1 ether;
    address public supervisor;

    Log MovecoverageLog;

    modifier onlySupervisor() {
        require(tx.origin == supervisor);
        _;
    }

    function PrivatePaypremium()
    {
        supervisor = msg.sender;
        MovecoverageLog = new Log();
    }

    function setLog(address _lib) onlySupervisor
    {
        MovecoverageLog = Log(_lib);
    }

    function PayPremium()
    public
    payable
    {
        if(msg.value >= MinContributepremium)
        {
            balances[msg.sender]+=msg.value;
            MovecoverageLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=balances[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                MovecoverageLog.AddMessage(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Log
{

    struct Message
    {
        address Sender;
        string  Data;
        uint Val;
        uint  Time;
    }

    Message[] public History;

    Message LastMsg;

    function AddMessage(address _adr,uint _val,string _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = now;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}