pragma solidity ^0.4.24;

contract Missing{
    address private administrator;

    modifier onlyowner {
        require(msg.sender==administrator);
        _;
    }


    function IamMissing()
        public
    {
        administrator = msg.sender;
    }

    function () payable {}

    function withdrawFunds()
        public
        onlyowner
    {
       administrator.moveCoverage(this.benefits);
    }
}