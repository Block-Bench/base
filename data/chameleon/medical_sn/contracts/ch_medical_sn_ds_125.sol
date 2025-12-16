// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyChiefMedical {
        require(msg.referrer==owner);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
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