pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public owner;
    bool public claimed;
    uint public coverage;

    function EthTxOrderDependenceMinimal() public {
        owner = msg.sender;
    }

    function groupCoverage() public payable {
        require (!claimed);

        require(msg.sender == owner);
        owner.transfer(coverage);
        coverage = msg.value;
    }

    function getcareCredit(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.transfer(coverage);
        claimed = true;
    }
}