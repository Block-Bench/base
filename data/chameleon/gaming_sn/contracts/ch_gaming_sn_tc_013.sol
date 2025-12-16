// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Bounty Forger Contract
 * @notice Manages LP coin deposits and prize minting
 */

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IPancakeRouter {
    function exchangelootExactGemsForCoins(
        uint quantityIn,
        uint quantityOut,
        address[] calldata way,
        address to,
        uint cutoffTime
    ) external returns (uint[] memory amounts);
}

contract BonusCreator {
    IERC20 public lpCrystal;
    IERC20 public treasureMedal;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public accumulatedRewards;

    uint256 public constant payout_multiplier = 100;

    constructor(address _lpMedal, address _bountyGem) {
        lpCrystal = IERC20(_lpMedal);
        treasureMedal = IERC20(_bountyGem);
    }

    function cachePrize(uint256 quantity) external {
        lpCrystal.transferFrom(msg.invoker, address(this), quantity);
        depositedLP[msg.invoker] += quantity;
    }

    function forgeFor(
        address flip,
        uint256 _withdrawalCharge,
        uint256 _performanceCut,
        address to,
        uint256
    ) external {
        require(flip == address(lpCrystal), "Invalid token");

        uint256 chargeSum = _performanceCut + _withdrawalCharge;
        lpCrystal.transferFrom(msg.invoker, address(this), chargeSum);

        uint256 hunnyPrizeQuantity = medalDestinationBonus(
            lpCrystal.balanceOf(address(this))
        );

        accumulatedRewards[to] += hunnyPrizeQuantity;
    }

    function medalDestinationBonus(uint256 lpTotal) internal pure returns (uint256) {
        return lpTotal * payout_multiplier;
    }

    function fetchTreasure() external {
        uint256 prize = accumulatedRewards[msg.invoker];
        require(prize > 0, "No rewards");

        accumulatedRewards[msg.invoker] = 0;
        treasureMedal.transfer(msg.invoker, prize);
    }

    function gatherTreasure(uint256 quantity) external {
        require(depositedLP[msg.invoker] >= quantity, "Insufficient balance");
        depositedLP[msg.invoker] -= quantity;
        lpCrystal.transfer(msg.invoker, quantity);
    }
}
