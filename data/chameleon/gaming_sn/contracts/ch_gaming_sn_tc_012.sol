// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending RewardEngine
 * @notice Manages security deposits and borrowing
 */

interface IComptroller {
    function enterquestMarkets(
        address[] memory cMedals
    ) external returns (uint256[] memory);

    function leavegameMarket(address cMedal) external returns (uint256);

    function acquireCharacterReserves(
        address profile
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public fullDeposits;
    uint256 public aggregateBorrowed;
    uint256 public constant security_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function bankwinningsAndEnterquestMarket() external payable {
        deposits[msg.caster] += msg.cost;
        fullDeposits += msg.cost;
        inMarket[msg.caster] = true;
    }

    function verifyHealthy(
        address profile,
        uint256 additionalRequestloan
    ) public view returns (bool) {
        uint256 aggregateOwing = borrowed[profile] + additionalRequestloan;
        if (aggregateOwing == 0) return true;

        if (!inMarket[profile]) return false;

        uint256 depositMagnitude = deposits[profile];
        return depositMagnitude >= (aggregateOwing * security_factor) / 100;
    }

    function seekAdvance(uint256 count) external {
        require(count > 0, "Invalid amount");
        require(address(this).balance >= count, "Insufficient funds");

        require(verifyHealthy(msg.caster, count), "Insufficient collateral");

        borrowed[msg.caster] += count;
        aggregateBorrowed += count;

        (bool win, ) = payable(msg.caster).call{cost: count}("");
        require(win, "Transfer failed");

        require(verifyHealthy(msg.caster, 0), "Health check failed");
    }

    function leavegameMarket() external {
        require(borrowed[msg.caster] == 0, "Outstanding debt");
        inMarket[msg.caster] = false;
    }

    function redeemTokens(uint256 count) external {
        require(deposits[msg.caster] >= count, "Insufficient deposits");
        require(!inMarket[msg.caster], "Exit market first");

        deposits[msg.caster] -= count;
        fullDeposits -= count;

        payable(msg.caster).transfer(count);
    }

    receive() external payable {}
}
