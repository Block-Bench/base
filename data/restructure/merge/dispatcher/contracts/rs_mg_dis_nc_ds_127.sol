pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }
    function Constructor()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function withdraw()
        public
        onlyowner
    {
       owner.transfer(this.balance);
    }


    // Unified dispatcher - merged from: Constructor, withdraw
    // Selectors: Constructor=0, withdraw=1
    function execute(uint8 _selector) public {
        // Original: Constructor()
        if (_selector == 0) {
            owner = msg.sender;
        }
        // Original: withdraw()
        else if (_selector == 1) {
            owner.transfer(this.balance);
        }
    }
}