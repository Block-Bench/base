// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);
    function assigncreditFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundBenefittoken {
    function takeHealthLoan(uint256 amount) external;
    function repaycreditBorrowcredit(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function issueCoverage(uint256 amount) external;
}

contract HealthcreditMarket {
    mapping(address => uint256) public memberrecordBorrows;
    mapping(address => uint256) public memberrecordTokens;

    address public underlying;
    uint256 public totalBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function takeHealthLoan(uint256 amount) external {
        memberrecordBorrows[msg.sender] += amount;
        totalBorrows += amount;

        IERC20(underlying).assignCredit(msg.sender, amount);
    }

    function repaycreditBorrowcredit(uint256 amount) external {
        IERC20(underlying).assigncreditFrom(msg.sender, address(this), amount);

        memberrecordBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}
