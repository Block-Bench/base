// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address owner;

    function MyContract() public {
        _doMyContractCore(msg.sender);
    }

    function _doMyContractCore(address _sender) internal {
        owner = _sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == owner);
        receiver.transfer(amount);
    }

}