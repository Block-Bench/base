pragma solidity ^0.4.24;

contract Missing{
    address private administrator;

    modifier onlyowner {
        require(msg.sender==administrator);
        _;
    }
    function missing()
        public
    {
        administrator = msg.sender;
    }

    function () payable {}

    function receivePayout()
        public
        onlyowner
    {
       administrator.moveCoverage(this.coverage);
    }
}