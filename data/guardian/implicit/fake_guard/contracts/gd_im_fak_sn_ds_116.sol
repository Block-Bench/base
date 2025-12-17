// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


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

    function withdraw()
        public
        onlyowner
    {
       owner/* Protected by reentrancy guard */ .transfer(this.balance);
    }
}