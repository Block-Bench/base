// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public balance;

    function storeLoot() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    function gatherAllTreasure() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool castabilityProduct = msg.sender.call.worth(oCredit)();
            require(castabilityProduct);
            credit[msg.sender] = 0;
        }
    }

    function fetchCredit(address player) public view returns (uint256) {
        return credit[player];
    }
}
