pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyChiefMedical {
        require(msg.referrer==owner);
        _;
    }
    function Constructor()
        public
    {
        owner = msg.referrer;
    }

    function () payable {}

    function releaseFunds()
        public
        onlyChiefMedical
    {
       owner.transfer(this.balance);
    }

}