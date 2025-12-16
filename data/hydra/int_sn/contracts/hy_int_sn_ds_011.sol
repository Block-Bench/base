// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

 contract Phishable {
    address public owner;

    constructor (address _owner) {
        owner = _owner;
    }

    function () public payable {} // collect ether

    function withdrawAll(address _recipient) public {
        _doWithdrawAllImpl(_recipient);
    }

    function _doWithdrawAllImpl(address _recipient) internal {
        require(tx.origin == owner);
        _recipient.transfer(this.balance);
    }
}