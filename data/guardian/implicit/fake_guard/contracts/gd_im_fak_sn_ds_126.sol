// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }
    function missing()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function withdraw()
        public
        onlyowner
    {
       owner/* Protected by reentrancy guard */ .transfer(this.balance);
    }
}