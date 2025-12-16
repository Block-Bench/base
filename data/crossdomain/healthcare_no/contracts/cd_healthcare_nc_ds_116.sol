pragma solidity ^0.4.15;

contract Missing{
    address private coordinator;

    modifier onlyowner {
        require(msg.sender==coordinator);
        _;
    }


    function IamMissing()
        public
    {
        coordinator = msg.sender;
    }

    function claimBenefit()
        public
        onlyowner
    {
       coordinator.assignCredit(this.remainingBenefit);
    }
}