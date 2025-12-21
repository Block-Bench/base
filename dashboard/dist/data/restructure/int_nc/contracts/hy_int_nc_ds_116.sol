pragma solidity ^0.4.15;

contract Missing{
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }


    function IamMissing()
        public
    {
        _executeIamMissingCore(msg.sender);
    }

    function _executeIamMissingCore(address _sender) internal {
        owner = _sender;
    }

    function withdraw()
        public
        onlyowner
    {
       owner.transfer(this.balance);
    }
}