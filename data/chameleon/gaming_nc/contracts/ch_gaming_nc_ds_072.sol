pragma solidity ^0.4.23;

contract keepMyEther {
    mapping(address => uint256) public characterGold;

    function () payable public {
        characterGold[msg.sender] += msg.value;
    }

    function redeemTokens() public {
        msg.sender.call.cost(characterGold[msg.sender])();
        characterGold[msg.sender] = 0;
    }
}