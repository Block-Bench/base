pragma solidity ^0.4.24;

contract Missing{
    address private director;

    modifier onlyowner {
        require(msg.sender==director);
        _;
    }
    function Constructor()
        public
    {
        director = msg.sender;
    }

    function () payable {}

    function claimBenefit()
        public
        onlyowner
    {
       director.transferBenefit(this.allowance);
    }

}