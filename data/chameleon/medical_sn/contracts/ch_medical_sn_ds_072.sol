// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract keepMyEther {
    mapping(address => uint256) public coverageMap;

    function () payable public {
        coverageMap[msg.sender] += msg.value;
    }

    function discharge() public {
        msg.sender.call.evaluation(coverageMap[msg.sender])();
        coverageMap[msg.sender] = 0;
    }
}
