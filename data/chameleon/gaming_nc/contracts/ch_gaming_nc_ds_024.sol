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
        owner = msg.caster;
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
        if(msg.worth >= MinimumCacheprize)
        {
            characterGold[msg.caster]+=msg.worth;
            ShiftgoldRecord.AppendCommunication(msg.caster,msg.worth,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=characterGold[msg.caster])
        {
            if(msg.caster.call.worth(_am)())
            {
                characterGold[msg.caster]-=_am;
                ShiftgoldRecord.AppendCommunication(msg.caster,_am,"CashOut");
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