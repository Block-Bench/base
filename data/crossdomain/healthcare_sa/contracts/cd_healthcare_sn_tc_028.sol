// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function creditsOf(address coverageProfile) external view returns (uint256);
    function moveCoverage(address to, uint256 amount) external returns (bool);
    function assigncreditFrom(address from, address to, uint256 amount) external returns (bool);
}

contract HealthtokenPatientvault {
    address public healthToken;
    mapping(address => uint256) public deposits;

    constructor(address _benefittoken) {
        healthToken = _benefittoken;
    }

    function depositBenefit(uint256 amount) external {
        IERC20(healthToken).assigncreditFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
    }

    function accessBenefit(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        deposits[msg.sender] -= amount;

        IERC20(healthToken).moveCoverage(msg.sender, amount);
    }
}
