pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyChiefMedical {
        require(msg.sender==owner);
        _;
    }
    function Constructor()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function releaseFunds()
        public
        onlyChiefMedical
    {
       owner.transfer(this.balance);
    }

}