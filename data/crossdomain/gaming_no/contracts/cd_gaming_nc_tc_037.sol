pragma solidity ^0.8.0;

interface IERC20 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address gamerProfile) external view returns (uint256);

    function allowTransfer(address spender, uint256 amount) external returns (bool);
}

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurveBountypool {
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

interface IItemloanLootpool {
    function cacheTreasure(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function requestLoan(
        address asset,
        uint256 amount,
        uint256 bonusrateBonusrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function claimLoot(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract UwuQuestcreditBountypool is IItemloanLootpool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function cacheTreasure(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).sharetreasureFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;
    }

    function requestLoan(
        address asset,
        uint256 amount,
        uint256 bonusrateBonusrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 betPrice = oracle.getAssetPrice(msg.sender);
        uint256 takeadvancePrice = oracle.getAssetPrice(asset);

        uint256 betValue = (deposits[msg.sender] * betPrice) /
            1e18;
        uint256 maxRequestloan = (betValue * LTV) / BASIS_POINTS;

        uint256 takeadvanceValue = (amount * takeadvancePrice) / 1e18;

        require(takeadvanceValue <= maxRequestloan, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).giveItems(onBehalfOf, amount);
    }

    function claimLoot(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).giveItems(to, amount);
        return amount;
    }
}

contract CurveOracle {
    ICurveBountypool public curveRewardpool;

    constructor(address _lootpool) {
        curveRewardpool = _lootpool;
    }

    function getAssetPrice(address asset) external view returns (uint256) {
        uint256 goldholding0 = curveRewardpool.balances(0);
        uint256 treasurecount1 = curveRewardpool.balances(1);

        uint256 price = (treasurecount1 * 1e18) / goldholding0;

        return price;
    }
}