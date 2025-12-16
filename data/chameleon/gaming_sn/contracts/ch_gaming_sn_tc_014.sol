// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title LootVault BattleStrategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Pool {
    function append_reserves(
        uint256[3] memory amounts,
        uint256 floor_summon_total
    ) external;

    function eliminate_reserves_imbalance(
        uint256[3] memory amounts,
        uint256 ceiling_consume_quantity
    ) external;

    function fetch_virtual_cost() external view returns (uint256);
}

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 sum) external returns (bool);
}

contract YieldVault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Pool public curve3Pool;

    mapping(address => uint256) public portions;
    uint256 public combinedSlices;
    uint256 public completeDeposits;

    uint256 public constant minimum_earn_limit = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Pool = ICurve3Pool(_curve3Pool);
    }

    function storeLoot(uint256 sum) external {
        dai.transferFrom(msg.invoker, address(this), sum);

        uint256 portionMeasure;
        if (combinedSlices == 0) {
            portionMeasure = sum;
        } else {
            portionMeasure = (sum * combinedSlices) / completeDeposits;
        }

        portions[msg.invoker] += portionMeasure;
        combinedSlices += portionMeasure;
        completeDeposits += sum;
    }

    function earn() external {
        uint256 vaultRewardlevel = dai.balanceOf(address(this));
        require(
            vaultRewardlevel >= minimum_earn_limit,
            "Insufficient balance to earn"
        );

        uint256 virtualValue = curve3Pool.fetch_virtual_cost();

        dai.approve(address(curve3Pool), vaultRewardlevel);
        uint256[3] memory amounts = [vaultRewardlevel, 0, 0];
        curve3Pool.append_reserves(amounts, 0);
    }

    function sweepWinnings() external {
        uint256 playerPortions = portions[msg.invoker];
        require(playerPortions > 0, "No shares");

        uint256 obtainprizeSum = (playerPortions * completeDeposits) / combinedSlices;

        portions[msg.invoker] = 0;
        combinedSlices -= playerPortions;
        completeDeposits -= obtainprizeSum;

        dai.transfer(msg.invoker, obtainprizeSum);
    }

    function balance() public view returns (uint256) {
        return
            dai.balanceOf(address(this)) +
            (crv3.balanceOf(address(this)) * curve3Pool.fetch_virtual_cost()) /
            1e18;
    }
}
