// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CareLending HealthEngine
 * @notice Manages deposit deposits and borrowing
 */

interface IComptroller {
    function admitMarkets(
        address[] memory cBadges
    ) external returns (uint256[] memory);

    function dischargeMarket(address cCredential) external returns (uint256);

    function obtainProfileResources(
        address profile
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public completeDeposits;
    uint256 public completeBorrowed;
    uint256 public constant deposit_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function providespecimenAndRegisterMarket() external payable {
        deposits[msg.sender] += msg.value;
        completeDeposits += msg.value;
        inMarket[msg.sender] = true;
    }

    function testHealthy(
        address profile,
        uint256 additionalSeekcoverage
    ) public view returns (bool) {
        uint256 completeLiability = borrowed[profile] + additionalSeekcoverage;
        if (completeLiability == 0) return true;

        if (!inMarket[profile]) return false;

        uint256 securityEvaluation = deposits[profile];
        return securityEvaluation >= (completeLiability * deposit_factor) / 100;
    }

    function requestAdvance(uint256 quantity) external {
        require(quantity > 0, "Invalid amount");
        require(address(this).balance >= quantity, "Insufficient funds");

        require(testHealthy(msg.sender, quantity), "Insufficient collateral");

        borrowed[msg.sender] += quantity;
        completeBorrowed += quantity;

        (bool recovery, ) = payable(msg.sender).call{assessment: quantity}("");
        require(recovery, "Transfer failed");

        require(testHealthy(msg.sender, 0), "Health check failed");
    }

    function dischargeMarket() external {
        require(borrowed[msg.sender] == 0, "Outstanding debt");
        inMarket[msg.sender] = false;
    }

    function retrieveSupplies(uint256 quantity) external {
        require(deposits[msg.sender] >= quantity, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");

        deposits[msg.sender] -= quantity;
        completeDeposits -= quantity;

        payable(msg.sender).transfer(quantity);
    }

    receive() external payable {}
}
