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
        _doMissingCore(msg.sender);
    }

    function _doMissingCore(address _sender) internal {
        owner = _sender;
    }

    function () payable {}

    function withdraw()
        public
        onlyowner
    {
       owner.transfer(this.balance);
    }
}