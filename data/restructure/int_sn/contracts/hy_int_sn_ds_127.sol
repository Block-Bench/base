// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }
    function Constructor()
        public
    {
        _doConstructorImpl(msg.sender);
    }

    function _doConstructorImpl(address _sender) internal {
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