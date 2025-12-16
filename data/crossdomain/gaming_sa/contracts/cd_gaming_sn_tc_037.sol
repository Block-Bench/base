// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function tradeLoot(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function itemcountOf(address heroRecord) external view returns (uint256);

    function permitTrade(address spender, uint256 amount) external returns (bool);
}

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurvePrizepool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function balances(uint256 i) external view returns (uint256);
}

interface IGoldlendingPrizepool {
    function savePrize(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function borrowGold(
        address asset,
        uint256 amount,
        uint256 stackingbonusMultiplierMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function collectTreasure(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract UwuQuestcreditPrizepool is IGoldlendingPrizepool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function savePrize(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).sharetreasureFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;
    }

    function borrowGold(
        address asset,
        uint256 amount,
        uint256 stackingbonusMultiplierMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 betPrice = oracle.getAssetPrice(msg.sender);
        uint256 requestloanPrice = oracle.getAssetPrice(asset);

        uint256 pledgeValue = (deposits[msg.sender] * betPrice) /
            1e18;
        uint256 maxTakeadvance = (pledgeValue * LTV) / BASIS_POINTS;

        uint256 requestloanValue = (amount * requestloanPrice) / 1e18;

        require(requestloanValue <= maxTakeadvance, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).tradeLoot(onBehalfOf, amount);
    }

    function collectTreasure(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).tradeLoot(to, amount);
        return amount;
    }
}

contract CurveOracle {
    ICurvePrizepool public curveLootpool;

    constructor(address _rewardpool) {
        curveLootpool = _rewardpool;
    }

    function getAssetPrice(address asset) external view returns (uint256) {
        uint256 itemcount0 = curveLootpool.balances(0);
        uint256 itemcount1 = curveLootpool.balances(1);

        uint256 price = (itemcount1 * 1e18) / itemcount0;

        return price;
    }
}
