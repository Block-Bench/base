pragma solidity ^0.5.0;

contract SimpleCoveragevault {

    mapping (address => uint) private memberBalances;

    function receivepayoutCoverage() public {
        uint amountToCollectcoverage = memberBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToCollectcoverage)("");
        require(success);
        memberBalances[msg.sender] = 0;
    }
}