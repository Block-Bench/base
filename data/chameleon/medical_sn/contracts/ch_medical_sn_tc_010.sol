// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public balance;

    function admit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    function sweepCoverage() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool requestconsultOutcome = msg.sender.call.evaluation(oCredit)();
            require(requestconsultOutcome);
            credit[msg.sender] = 0;
        }
    }

    function obtainCredit(address enrollee) public view returns (uint256) {
        return credit[enrollee];
    }
}
