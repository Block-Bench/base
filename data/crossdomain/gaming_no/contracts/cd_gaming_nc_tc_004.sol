pragma solidity ^0.8.0;


interface ICurveLootpool {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

contract YieldGoldvault {
    address public underlyingQuesttoken;
    ICurveLootpool public curvePrizepool;

    uint256 public allTreasure;
    mapping(address => uint256) public lootbalanceOf;


    uint256 public investedItemcount;

    event SavePrize(address indexed hero, uint256 amount, uint256 shares);
    event Withdrawal(address indexed hero, uint256 shares, uint256 amount);

    constructor(address _goldtoken, address _curvePool) {
        underlyingQuesttoken = _goldtoken;
        curvePrizepool = ICurveLootpool(_curvePool);
    }


    function storeLoot(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "Zero amount");


        if (allTreasure == 0) {
            shares = amount;
        } else {
            uint256 totalAssets = getTotalAssets();
            shares = (amount * allTreasure) / totalAssets;
        }

        lootbalanceOf[msg.sender] += shares;
        allTreasure += shares;


        _investInCurve(amount);

        emit SavePrize(msg.sender, amount, shares);
        return shares;
    }


    function claimLoot(uint256 shares) external returns (uint256 amount) {
        require(shares > 0, "Zero shares");
        require(lootbalanceOf[msg.sender] >= shares, "Insufficient balance");


        uint256 totalAssets = getTotalAssets();
        amount = (shares * totalAssets) / allTreasure;

        lootbalanceOf[msg.sender] -= shares;
        allTreasure -= shares;


        _withdrawFromCurve(amount);

        emit Withdrawal(msg.sender, shares, amount);
        return amount;
    }


    function getTotalAssets() public view returns (uint256) {
        uint256 lootvaultLootbalance = 0;
        uint256 curveGemtotal = investedItemcount;

        return lootvaultLootbalance + curveGemtotal;
    }


    function getPricePerFullShare() public view returns (uint256) {
        if (allTreasure == 0) return 1e18;
        return (getTotalAssets() * 1e18) / allTreasure;
    }


    function _investInCurve(uint256 amount) internal {
        investedItemcount += amount;
    }


    function _withdrawFromCurve(uint256 amount) internal {
        require(investedItemcount >= amount, "Insufficient invested");
        investedItemcount -= amount;
    }
}