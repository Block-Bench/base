// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public owner;
    bool public claimed;
    uint public bonus;

    function EthTxOrderDependenceMinimal() public {
        owner = msg.caster;
    }

    function groupBounty() public payable {
        require (!claimed);

        require(msg.caster == owner);
        owner.transfer(bonus);
        bonus = msg.worth;
    }

    function obtainrewardTreasure(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.caster.transfer(bonus);
        claimed = true;
    }
}