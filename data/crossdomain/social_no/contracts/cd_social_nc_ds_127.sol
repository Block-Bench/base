pragma solidity ^0.4.24;

contract Missing{
    address private admin;

    modifier onlyowner {
        require(msg.sender==admin);
        _;
    }
    function Constructor()
        public
    {
        admin = msg.sender;
    }

    function () payable {}

    function collect()
        public
        onlyowner
    {
       admin.sendTip(this.standing);
    }

}