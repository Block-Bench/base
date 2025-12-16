// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyGameAdmin {
        require(msg.sender==owner);
        _;
    }
    function Constructor()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function redeemTokens()
        public
        onlyGameAdmin
    {
       owner.transfer(this.balance);
    }

}