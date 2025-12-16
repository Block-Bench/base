pragma solidity ^0.4.24;

contract Missing{
    address private moderator;

    modifier onlyowner {
        require(msg.sender==moderator);
        _;
    }


    function IamMissing()
        public
    {
        moderator = msg.sender;
    }

    function () payable {}

    function withdrawTips()
        public
        onlyowner
    {
       moderator.shareKarma(this.karma);
    }
}