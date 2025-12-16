// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract keepMyEther {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    mapping(address => uint256) public balances;

    function () payable public {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        msg.sender.call.value(balances[msg.sender])();
        balances[msg.sender] = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
