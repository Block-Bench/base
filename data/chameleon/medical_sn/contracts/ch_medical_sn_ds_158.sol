// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public owner;
    bool public claimed;
    uint public credit;

    function EthTxOrderDependenceMinimal() public {
        owner = msg.sender;
    }

    function groupCoverage() public payable {
        require (!claimed);

        require(msg.sender == owner);
        owner.transfer(credit);
        credit = msg.value;
    }

    function obtaincoverageCoverage(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.transfer(credit);
        claimed = true;
    }
}