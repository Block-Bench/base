// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract DAO {
    mapping(address => uint256) public credit;
    uint256 public balance;

    function deposit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    function withdrawAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            credit[msg.sender] = 0;
            balance -= oCredit;
            (bool callResult, ) = msg.sender.call{value: oCredit}("");
            require(callResult);
        }
    }

    function getCredit(address user) public view returns (uint256) {
        return credit[user];
    }
}
