// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract keepMyEther  is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function () payable public {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public nonReentrant {
        msg.sender.call.value(balances[msg.sender])();
        balances[msg.sender] = 0;
    }
}
