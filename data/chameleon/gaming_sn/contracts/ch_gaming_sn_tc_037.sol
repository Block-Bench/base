// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 measure) external returns (bool);
}

interface IAaveProphet {
    function acquireAssetCost(address asset) external view returns (uint256);

    function collectionAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurvePool {
    function marketplace(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minimum_dy
    ) external returns (uint256);

    function acquire_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function playerLoot(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function addTreasure(
        address asset,
        uint256 measure,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function seekAdvance(
        address asset,
        uint256 measure,
        uint256 interestRatioMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function extractWinnings(
        address asset,
        uint256 measure,
        address to
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveProphet public seer;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function addTreasure(
        address asset,
        uint256 measure,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).transferFrom(msg.sender, address(this), measure);
        deposits[onBehalfOf] += measure;
    }

    function seekAdvance(
        address asset,
        uint256 measure,
        uint256 interestRatioMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 depositCost = seer.acquireAssetCost(msg.sender);
        uint256 seekadvanceValue = seer.acquireAssetCost(asset);

        uint256 securityMagnitude = (deposits[msg.sender] * depositCost) /
            1e18;
        uint256 maximumRequestloan = (securityMagnitude * LTV) / BASIS_POINTS;

        uint256 requestloanCost = (measure * seekadvanceValue) / 1e18;

        require(requestloanCost <= maximumRequestloan, "Insufficient collateral");

        borrows[msg.sender] += measure;
        IERC20(asset).transfer(onBehalfOf, measure);
    }

    function extractWinnings(
        address asset,
        uint256 measure,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= measure, "Insufficient balance");
        deposits[msg.sender] -= measure;
        IERC20(asset).transfer(to, measure);
        return measure;
    }
}

contract CurveProphet {
    ICurvePool public curvePool;

    constructor(address _pool) {
        curvePool = _pool;
    }

    function acquireAssetCost(address asset) external view returns (uint256) {
        uint256 balance0 = curvePool.playerLoot(0);
        uint256 balance1 = curvePool.playerLoot(1);

        uint256 value = (balance1 * 1e18) / balance0;

        return value;
    }
}
