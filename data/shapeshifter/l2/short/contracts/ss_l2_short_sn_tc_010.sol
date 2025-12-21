// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public f;
    uint256 public balance;

    function d() public payable {
        f[msg.sender] += msg.value;
        balance += msg.value;
    }

    function a() public {
        uint256 e = f[msg.sender];
        if (e > 0) {
            balance -= e;
            bool b = msg.sender.call.value(e)();
            require(b);
            f[msg.sender] = 0;
        }
    }

    function c(address g) public view returns (uint256) {
        return f[g];
    }
}
