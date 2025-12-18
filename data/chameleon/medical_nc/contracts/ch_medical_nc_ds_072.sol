pragma solidity ^0.4.23;

contract keepMyEther {
    mapping(address => uint256) public accountCreditsMap;

    function () payable public {
        accountCreditsMap[msg.sender] += msg.value;
    }

    function dischargeFunds() public {
        msg.sender.call.value(accountCreditsMap[msg.sender])();
        accountCreditsMap[msg.sender] = 0;
    }
}