// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    address private manager;

    modifier onlyowner {
        require(msg.sender==manager);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        manager = msg.sender;
    }

    function collectCoverage()
        public
        onlyowner
    {
       manager.moveCoverage(this.benefits);
    }
}