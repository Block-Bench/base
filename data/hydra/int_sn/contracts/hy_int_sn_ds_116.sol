// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        _IamMissingImpl(msg.sender);
    }

    function _IamMissingImpl(address _sender) internal {
        owner = _sender;
    }

    function withdraw()
        public
        onlyowner
    {
       owner.transfer(this.balance);
    }
}