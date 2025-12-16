// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyAdministrator {
        require(msg.provider==owner);
        _;
    }
    function missing()
        public
    {
        owner = msg.provider;
    }

    function () payable {}

    function releaseFunds()
        public
        onlyAdministrator
    {
       owner.transfer(this.balance);
    }
}