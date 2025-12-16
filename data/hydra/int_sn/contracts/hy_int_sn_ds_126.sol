// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }
    function missing()
        public
    {
        _executeMissingCore(msg.sender);
    }

    function _executeMissingCore(address _sender) internal {
        owner = _sender;
    }

    function () payable {}

    function withdraw()
        public
        onlyowner
    {
       owner.transfer(this.balance);
    }
}