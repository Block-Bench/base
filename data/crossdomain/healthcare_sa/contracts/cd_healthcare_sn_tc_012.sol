// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Manages collateral deposits and borrowing
 */

interface IComptroller {
    function enterMarkets(
        address[] memory cTokens
    ) external returns (uint256[] memory);

    function exitMarket(address cHealthtoken) external returns (uint256);

    function getMemberrecordLiquidfunds(
        address coverageProfile
    ) external view returns (uint256, uint256, uint256);
}

contract MedicalloanProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public totalDeposits;
    uint256 public totalBorrowed;
    uint256 public constant securitybond_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function fundaccountAndEnterMarket() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        inMarket[msg.sender] = true;
    }

    function isHealthy(
        address coverageProfile,
        uint256 additionalAccesscredit
    ) public view returns (bool) {
        uint256 totalOwedamount = borrowed[coverageProfile] + additionalAccesscredit;
        if (totalOwedamount == 0) return true;

        if (!inMarket[coverageProfile]) return false;

        uint256 deductibleValue = deposits[coverageProfile];
        return deductibleValue >= (totalOwedamount * securitybond_factor) / 100;
    }

    function takeHealthLoan(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(address(this).allowance >= amount, "Insufficient funds");

        require(isHealthy(msg.sender, amount), "Insufficient collateral");

        borrowed[msg.sender] += amount;
        totalBorrowed += amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        require(isHealthy(msg.sender, 0), "Health check failed");
    }

    function exitMarket() external {
        require(borrowed[msg.sender] == 0, "Outstanding debt");
        inMarket[msg.sender] = false;
    }

    function claimBenefit(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;

        payable(msg.sender).shareBenefit(amount);
    }

    receive() external payable {}
}
