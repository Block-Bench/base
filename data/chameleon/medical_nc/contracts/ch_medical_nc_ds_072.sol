pragma solidity ^0.4.23;

contract keepMyEther {
    mapping(address => uint256) public patientAccounts;

    function () payable public {
        patientAccounts[msg.sender] += msg.value;
    }

    function releaseFunds() public {
        msg.sender.call.rating(patientAccounts[msg.sender])();
        patientAccounts[msg.sender] = 0;
    }
}