// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyAdministrator {
        require(msg.sender==owner);
        _;
    }
    function missing()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function releaseFunds()
        public
        onlyAdministrator
    {
       owner.transfer(this.balance);
    }
}