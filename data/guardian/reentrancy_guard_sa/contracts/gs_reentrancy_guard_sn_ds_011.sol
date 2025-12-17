// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


 contract Phishable  is ReentrancyGuard {
    address public owner;

    constructor (address _owner) {
        owner = _owner;
    }

    function () public payable {} // collect ether

    function withdrawAll(address _recipient) public nonReentrant {
        require(tx.origin == owner);
        _recipient.transfer(this.balance);
    }
}