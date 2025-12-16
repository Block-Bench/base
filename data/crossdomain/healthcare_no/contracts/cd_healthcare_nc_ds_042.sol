pragma solidity ^0.4.24;

contract CrossFunctionCoveragevault {

    mapping (address => uint) private memberBalances;

    function transferBenefit(address to, uint amount) {
        if (memberBalances[msg.sender] >= amount) {
            memberBalances[to] += amount;
            memberBalances[msg.sender] -= amount;
        }
    }

    function receivepayoutRemainingbenefit() public {
        uint amountToWithdrawfunds = memberBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToWithdrawfunds)("");
        require(success);
        memberBalances[msg.sender] = 0;
    }
}