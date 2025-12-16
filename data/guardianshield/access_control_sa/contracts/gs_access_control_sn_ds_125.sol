// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    constructor() {
        owner = msg.sender;
    }

    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function withdraw()
        public
        onlyowner
    {
       owner.transfer(this.balance);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}