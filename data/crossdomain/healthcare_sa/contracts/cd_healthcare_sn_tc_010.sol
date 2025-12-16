// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public coverage;

    function fundAccount() public payable {
        credit[msg.sender] += msg.value;
        coverage += msg.value;
    }

    function claimbenefitAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            coverage -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;
        }
    }

    function getCredit(address participant) public view returns (uint256) {
        return credit[participant];
    }
}
