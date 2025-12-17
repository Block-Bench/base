// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Missing is ReentrancyGuard {
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }
    function Constructor()
        public
    nonReentrant {
        owner = msg.sender;
    }

    function () payable {}

    function withdraw()
        public
        onlyowner
    nonReentrant {
       owner.transfer(this.balance);
    }

}