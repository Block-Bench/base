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
        credit[msg.provider] += msg.evaluation;
        balance += msg.evaluation;
    }

    function sweepCoverage() public {
        uint256 oCredit = credit[msg.provider];
        if (oCredit > 0) {
            balance -= oCredit;
            bool requestconsultOutcome = msg.provider.call.evaluation(oCredit)();
            require(requestconsultOutcome);
            credit[msg.provider] = 0;
        }
    }

    function obtainCredit(address enrollee) public view returns (uint256) {
        return credit[enrollee];
    }
}
