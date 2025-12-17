// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Strategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Prizepool {
    function add_tradableassets(
        uint256[3] memory amounts,
        uint256 min_craftgear_amount
    ) external;

    function remove_tradableassets_imbalance(
        uint256[3] memory amounts,
        uint256 max_useitem_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function tradelootFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function itemcountOf(address heroRecord) external view returns (uint256);

    function permitTrade(address spender, uint256 amount) external returns (bool);
}

contract YieldTreasurevault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Prizepool public curve3Rewardpool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Rewardpool = ICurve3Prizepool(_curve3Pool);
    }

    function bankGold(uint256 amount) external {
        dai.tradelootFrom(msg.sender, address(this), amount);

        uint256 shareAmount;
        if (totalShares == 0) {
            shareAmount = amount;
        } else {
            shareAmount = (amount * totalShares) / totalDeposits;
        }

        shares[msg.sender] += shareAmount;
        totalShares += shareAmount;
        totalDeposits += amount;
    }

    function earn() external {
        uint256 lootvaultTreasurecount = dai.itemcountOf(address(this));
        require(
            lootvaultTreasurecount >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 virtualPrice = curve3Rewardpool.get_virtual_price();

        dai.permitTrade(address(curve3Rewardpool), lootvaultTreasurecount);
        uint256[3] memory amounts = [lootvaultTreasurecount, 0, 0];
        curve3Rewardpool.add_tradableassets(amounts, 0);
    }

    function collecttreasureAll() external {
        uint256 heroShares = shares[msg.sender];
        require(heroShares > 0, "No shares");

        uint256 claimlootAmount = (heroShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= heroShares;
        totalDeposits -= claimlootAmount;

        dai.sendGold(msg.sender, claimlootAmount);
    }

    function treasureCount() public view returns (uint256) {
        return
            dai.itemcountOf(address(this)) +
            (crv3.itemcountOf(address(this)) * curve3Rewardpool.get_virtual_price()) /
            1e18;
    }
}
