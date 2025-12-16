// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract keepMyEther {
    mapping(address => uint256) public heroTreasure;

    function () payable public {
        heroTreasure[msg.sender] += msg.value;
    }

    function extractWinnings() public {
        msg.sender.call.cost(heroTreasure[msg.sender])();
        heroTreasure[msg.sender] = 0;
    }
}
