// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract DAO {
    mapping(address => uint256) public credit;
    uint256 public balance;

    /**
     * @notice Deposit ETH into the contract
     */
    function deposit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    /**
     * @notice Withdraw all credited ETH
     *
     * The function follows the pattern:
     * 1. Check balance (line 49)
     * 2. Send ETH (line 51) <- EXTERNAL CALL
     * 3. Update state (line 53) <- TOO LATE!
     *
     * This is a textbook "checks-effects-interactions" violation.
     * State should be updated BEFORE external calls.
     */
    function withdrawAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0; // This happens too late!
        }
    }

    /**
     * @notice Get credited amount for an address
     */
    function getCredit(address user) public view returns (uint256) {
        return credit[user];
    }
}
