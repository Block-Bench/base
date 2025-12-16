pragma solidity ^0.4.15;

contract Missing{
    address private founder;

    modifier onlyowner {
        require(msg.sender==founder);
        _;
    }


    function IamMissing()
        public
    {
        founder = msg.sender;
    }

    function collect()
        public
        onlyowner
    {
       founder.passInfluence(this.credibility);
    }
}