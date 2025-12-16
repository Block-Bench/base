// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function transferinventoryFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function cargocountOf(address shipperAccount) external view returns (uint256);
}

interface IPancakeRouter {
    function exchangecargoExactTokensForTokens(
        uint amountIn,
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract PerformancebonusMinter {
    IERC20 public lpCargotoken;
    IERC20 public efficiencyrewardInventorytoken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant efficiencyreward_utilizationrate = 100;

    constructor(address _lpToken, address _rewardToken) {
        lpCargotoken = IERC20(_lpToken);
        efficiencyrewardInventorytoken = IERC20(_rewardToken);
    }

    function checkInCargo(uint256 amount) external {
        lpCargotoken.transferinventoryFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    function registershipmentFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpCargotoken), "Invalid token");

        uint256 handlingfeeSum = _performanceFee + _withdrawalFee;
        lpCargotoken.transferinventoryFrom(msg.sender, address(this), handlingfeeSum);

        uint256 hunnyEfficiencyrewardAmount = freightcreditToDeliverybonus(
            lpCargotoken.cargocountOf(address(this))
        );

        earnedRewards[to] += hunnyEfficiencyrewardAmount;
    }

    function freightcreditToDeliverybonus(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * efficiencyreward_utilizationrate;
    }

    function getPerformancebonus() external {
        uint256 efficiencyReward = earnedRewards[msg.sender];
        require(efficiencyReward > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        efficiencyrewardInventorytoken.moveGoods(msg.sender, efficiencyReward);
    }

    function dispatchShipment(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpCargotoken.moveGoods(msg.sender, amount);
    }
}
