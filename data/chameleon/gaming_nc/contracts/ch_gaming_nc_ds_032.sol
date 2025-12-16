pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public userRewards;

    uint public FloorAddtreasure = 1 ether;

    Journal RelocateassetsJournal;

    function PrivateBank(address _lib)
    {
        RelocateassetsJournal = Journal(_lib);
    }

    function StashRewards()
    public
    payable
    {
        if(msg.worth >= FloorAddtreasure)
        {
            userRewards[msg.invoker]+=msg.worth;
            RelocateassetsJournal.IncludeSignal(msg.invoker,msg.worth,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=userRewards[msg.invoker])
        {
            if(msg.invoker.call.worth(_am)())
            {
                userRewards[msg.invoker]-=_am;
                RelocateassetsJournal.IncludeSignal(msg.invoker,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Journal
{

    struct Communication
    {
        address Caster;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Communication[] public History;

    Communication EndingMsg;

    function IncludeSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}