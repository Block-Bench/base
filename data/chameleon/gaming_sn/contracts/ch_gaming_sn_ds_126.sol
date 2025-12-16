// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyGameAdmin {
        require(msg.sender==owner);
        _;
    }
    function missing()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function collectBounty()
        public
        onlyGameAdmin
    {
       owner.transfer(this.balance);
    }
}