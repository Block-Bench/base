// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyChiefMedical {
        require(msg.provider==owner);
        _;
    }
    function Constructor()
        public
    {
        owner = msg.provider;
    }

    function () payable {}

    function withdrawBenefits()
        public
        onlyChiefMedical
    {
       owner.transfer(this.balance);
    }

}