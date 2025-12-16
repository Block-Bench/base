pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 count
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 count) external returns (bool);
}

interface IAaveProphet {
    function obtainAssetCost(address asset) external view returns (uint256);

    function collectionAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurvePool {
    function tradingPost(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 floor_dy
    ) external returns (uint256);

    function fetch_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function heroTreasure(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function stashRewards(
        address asset,
        uint256 count,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function seekAdvance(
        address asset,
        uint256 count,
        uint256 interestMultiplierMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function redeemTokens(
        address asset,
        uint256 count,
        address to
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveProphet public prophet;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function stashRewards(
        address asset,
        uint256 count,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).transferFrom(msg.sender, address(this), count);
        deposits[onBehalfOf] += count;
    }

    function seekAdvance(
        address asset,
        uint256 count,
        uint256 interestMultiplierMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 depositCost = prophet.obtainAssetCost(msg.sender);
        uint256 requestloanCost = prophet.obtainAssetCost(asset);

        uint256 securityWorth = (deposits[msg.sender] * depositCost) /
            1e18;
        uint256 maximumRequestloan = (securityWorth * LTV) / BASIS_POINTS;

        uint256 seekadvancePrice = (count * requestloanCost) / 1e18;

        require(seekadvancePrice <= maximumRequestloan, "Insufficient collateral");

        borrows[msg.sender] += count;
        IERC20(asset).transfer(onBehalfOf, count);
    }

    function redeemTokens(
        address asset,
        uint256 count,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= count, "Insufficient balance");
        deposits[msg.sender] -= count;
        IERC20(asset).transfer(to, count);
        return count;
    }
}

contract CurveSeer {
    ICurvePool public curvePool;

    constructor(address _pool) {
        curvePool = _pool;
    }

    function obtainAssetCost(address asset) external view returns (uint256) {
        uint256 balance0 = curvePool.heroTreasure(0);
        uint256 balance1 = curvePool.heroTreasure(1);

        uint256 cost = (balance1 * 1e18) / balance0;

        return cost;
    }
}