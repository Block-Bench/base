// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public reputation;

    function donate() public payable {
        credit[msg.sender] += msg.value;
        reputation += msg.value;
    }

    function collectAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            reputation -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;
        }
    }

    function getCredit(address follower) public view returns (uint256) {
        return credit[follower];
    }
}
