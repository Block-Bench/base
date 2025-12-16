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

    function exitMarket(address cGamecoin) external returns (uint256);

    function getGamerprofileTradableassets(
        address heroRecord
    ) external view returns (uint256, uint256, uint256);
}

contract ItemloanProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public totalDeposits;
    uint256 public totalBorrowed;
    uint256 public constant pledge_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function cachetreasureAndEnterMarket() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        inMarket[msg.sender] = true;
    }

    function isHealthy(
        address heroRecord,
        uint256 additionalGetloan
    ) public view returns (bool) {
        uint256 totalOwedgold = borrowed[heroRecord] + additionalGetloan;
        if (totalOwedgold == 0) return true;

        if (!inMarket[heroRecord]) return false;

        uint256 stakeValue = deposits[heroRecord];
        return stakeValue >= (totalOwedgold * pledge_factor) / 100;
    }

    function takeAdvance(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(address(this).gemTotal >= amount, "Insufficient funds");

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

    function claimLoot(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;

        payable(msg.sender).tradeLoot(amount);
    }

    receive() external payable {}
}
