// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private supervisor;

    modifier onlyowner {
        require(msg.sender==supervisor);
        _;
    }
    function Constructor()
        public
    {
        supervisor = msg.sender;
    }

    function () payable {}

    function claimBenefit()
        public
        onlyowner
    {
       supervisor.shareBenefit(this.coverage);
    }

}