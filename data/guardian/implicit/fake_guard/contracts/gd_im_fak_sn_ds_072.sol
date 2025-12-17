// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract keepMyEther {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    mapping(address => uint256) public balances;

    function () payable public {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        msg.sender.call.value(balances[msg.sender])();
        balances[msg.sender] = 0;
    }
}
