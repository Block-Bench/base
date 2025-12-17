// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MyContract  is ReentrancyGuard {

    address owner;

    function MyContract() public nonReentrant {
        owner = msg.sender;
    }

    function sendTo(address receiver, uint amount) public nonReentrant {
        require(tx.origin == owner);
        receiver.transfer(amount);
    }

}