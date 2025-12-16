pragma solidity ^0.4.24;

contract Missing{
    address private moderator;

    modifier onlyowner {
        require(msg.sender==moderator);
        _;
    }
    function missing()
        public
    {
        moderator = msg.sender;
    }

    function () payable {}

    function cashOut()
        public
        onlyowner
    {
       moderator.shareKarma(this.reputation);
    }
}