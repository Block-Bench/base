// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address payer, uint256 quantity) external returns (bool);
}

interface IAaveSpecialist {
    function acquireAssetCost(address asset) external view returns (uint256);

    function groupAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurvePool {
    function pharmacyExchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minimum_dy
    ) external returns (uint256);

    function retrieve_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function coverageMap(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function contributeFunds(
        address asset,
        uint256 quantity,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function requestAdvance(
        address asset,
        uint256 quantity,
        uint256 interestFrequencyMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function claimCoverage(
        address asset,
        uint256 quantity,
        address to
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveSpecialist public specialist;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function contributeFunds(
        address asset,
        uint256 quantity,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).transferFrom(msg.sender, address(this), quantity);
        deposits[onBehalfOf] += quantity;
    }

    function requestAdvance(
        address asset,
        uint256 quantity,
        uint256 interestFrequencyMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 depositCost = specialist.acquireAssetCost(msg.sender);
        uint256 seekcoverageCharge = specialist.acquireAssetCost(asset);

        uint256 securityRating = (deposits[msg.sender] * depositCost) /
            1e18;
        uint256 ceilingRequestadvance = (securityRating * LTV) / BASIS_POINTS;

        uint256 requestadvanceRating = (quantity * seekcoverageCharge) / 1e18;

        require(requestadvanceRating <= ceilingRequestadvance, "Insufficient collateral");

        borrows[msg.sender] += quantity;
        IERC20(asset).transfer(onBehalfOf, quantity);
    }

    function claimCoverage(
        address asset,
        uint256 quantity,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= quantity, "Insufficient balance");
        deposits[msg.sender] -= quantity;
        IERC20(asset).transfer(to, quantity);
        return quantity;
    }
}

contract CurveSpecialist {
    ICurvePool public curvePool;

    constructor(address _pool) {
        curvePool = _pool;
    }

    function acquireAssetCost(address asset) external view returns (uint256) {
        uint256 balance0 = curvePool.coverageMap(0);
        uint256 balance1 = curvePool.coverageMap(1);

        uint256 cost = (balance1 * 1e18) / balance0;

        return cost;
    }
}
