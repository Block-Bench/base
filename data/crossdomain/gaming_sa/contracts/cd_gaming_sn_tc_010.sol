// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public lootBalance;

    function cacheTreasure() public payable {
        credit[msg.sender] += msg.value;
        lootBalance += msg.value;
    }

    function claimlootAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            lootBalance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;
        }
    }

    function getCredit(address warrior) public view returns (uint256) {
        return credit[warrior];
    }
}
