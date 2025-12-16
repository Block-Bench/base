pragma solidity ^0.4.24;

contract CrossFunctionCommunityvault {

    mapping (address => uint) private creatorBalances;

    function sendTip(address to, uint amount) {
        if (creatorBalances[msg.sender] >= amount) {
            creatorBalances[to] += amount;
            creatorBalances[msg.sender] -= amount;
        }
    }

    function cashoutCredibility() public {
        uint amountToWithdrawtips = creatorBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToWithdrawtips)("");
        require(success);
        creatorBalances[msg.sender] = 0;
    }
}