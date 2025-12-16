pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint releasecoverageMoment;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public FloorSum;

    RecordFile Record;

    bool intitalized;

    function CollectionMinimumSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function CollectionRecordFile(address _log)
    public
    {
        if(intitalized)throw;
        Record = RecordFile(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function Put(uint _bindcoverageMoment)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        if(now+_bindcoverageMoment>acc.releasecoverageMoment)acc.releasecoverageMoment=now+_bindcoverageMoment;
        Record.AttachAlert(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.releasecoverageMoment)
        {
            if(msg.sender.call.rating(_am)())
            {
                acc.balance-=_am;
                Record.AttachAlert(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

}

contract RecordFile
{
    struct Notification
    {
        address Referrer;
        string  Chart;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AttachAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart = _data;
        History.push(EndingMsg);
    }
}