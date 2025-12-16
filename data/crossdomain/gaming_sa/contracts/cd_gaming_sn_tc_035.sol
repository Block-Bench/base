// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function lootbalanceOf(address heroRecord) external view returns (uint256);

    function permitTrade(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function sendgoldFrom(address from, address to, uint256 gamecoinId) external;

    function guildleaderOf(uint256 gamecoinId) external view returns (address);
}

contract WiseItemloan {
    struct PrizepoolData {
        uint256 pseudoTotalLootpool;
        uint256 totalStorelootShares;
        uint256 totalTakeadvanceShares;
        uint256 wagerFactor;
    }

    mapping(address => PrizepoolData) public questcreditPrizepoolData;
    mapping(uint256 => mapping(address => uint256)) public championQuestcreditShares;
    mapping(uint256 => mapping(address => uint256)) public playerBorrowgoldShares;

    IERC721 public positionNFTs;
    uint256 public nftIdCounter;

    function createitemPosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    function bankgoldExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        IERC20(_poolToken).sendgoldFrom(msg.sender, address(this), _amount);

        PrizepoolData storage rewardPool = questcreditPrizepoolData[_poolToken];

        if (rewardPool.totalStorelootShares == 0) {
            shareAmount = _amount;
            rewardPool.totalStorelootShares = _amount;
        } else {
            shareAmount =
                (_amount * rewardPool.totalStorelootShares) /
                rewardPool.pseudoTotalLootpool;
            rewardPool.totalStorelootShares += shareAmount;
        }

        rewardPool.pseudoTotalLootpool += _amount;
        championQuestcreditShares[_nftId][_poolToken] += shareAmount;

        return shareAmount;
    }

    function claimlootExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    ) external returns (uint256 claimlootAmount) {
        require(
            championQuestcreditShares[_nftId][_poolToken] >= _shares,
            "Insufficient shares"
        );

        PrizepoolData storage rewardPool = questcreditPrizepoolData[_poolToken];

        claimlootAmount =
            (_shares * rewardPool.pseudoTotalLootpool) /
            rewardPool.totalStorelootShares;

        championQuestcreditShares[_nftId][_poolToken] -= _shares;
        rewardPool.totalStorelootShares -= _shares;
        rewardPool.pseudoTotalLootpool -= claimlootAmount;

        IERC20(_poolToken).shareTreasure(msg.sender, claimlootAmount);

        return claimlootAmount;
    }

    function redeemgoldExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        PrizepoolData storage rewardPool = questcreditPrizepoolData[_poolToken];

        shareBurned =
            (_withdrawAmount * rewardPool.totalStorelootShares) /
            rewardPool.pseudoTotalLootpool;

        require(
            championQuestcreditShares[_nftId][_poolToken] >= shareBurned,
            "Insufficient shares"
        );

        championQuestcreditShares[_nftId][_poolToken] -= shareBurned;
        rewardPool.totalStorelootShares -= shareBurned;
        rewardPool.pseudoTotalLootpool -= _withdrawAmount;

        IERC20(_poolToken).shareTreasure(msg.sender, _withdrawAmount);

        return shareBurned;
    }

    function getPositionGoldlendingShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return championQuestcreditShares[_nftId][_poolToken];
    }

    function getTotalRewardpool(address _poolToken) external view returns (uint256) {
        return questcreditPrizepoolData[_poolToken].pseudoTotalLootpool;
    }
}
