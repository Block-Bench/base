pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }
    function missing()
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

    // Unified dispatcher - merged from: missing, withdraw
    // Selectors: missing=0, withdraw=1
    function execute(uint8 _selector) public {
        // Original: missing()
        if (_selector == 0) {
            owner = msg.sender;
        }
        // Original: withdraw()
        else if (_selector == 1) {
            owner.transfer(this.balance);
        }
    }
}