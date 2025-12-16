pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function lootbalanceOf(address heroRecord) external view returns (uint256);

    function authorizeDeal(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function sharetreasureFrom(address from, address to, uint256 questtokenId) external;

    function gamemasterOf(uint256 questtokenId) external view returns (address);
}

contract WiseQuestcredit {
    struct LootpoolData {
        uint256 pseudoTotalPrizepool;
        uint256 totalStashitemsShares;
        uint256 totalRequestloanShares;
        uint256 stakeFactor;
    }

    mapping(address => LootpoolData) public goldlendingBountypoolData;
    mapping(uint256 => mapping(address => uint256)) public gamerQuestcreditShares;
    mapping(uint256 => mapping(address => uint256)) public championRequestloanShares;

    IERC721 public positionNFTs;
    uint256 public nftIdCounter;

    function craftgearPosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    function bankgoldExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        IERC20(_poolToken).sharetreasureFrom(msg.sender, address(this), _amount);

        LootpoolData storage prizePool = goldlendingBountypoolData[_poolToken];

        if (prizePool.totalStashitemsShares == 0) {
            shareAmount = _amount;
            prizePool.totalStashitemsShares = _amount;
        } else {
            shareAmount =
                (_amount * prizePool.totalStashitemsShares) /
                prizePool.pseudoTotalPrizepool;
            prizePool.totalStashitemsShares += shareAmount;
        }

        prizePool.pseudoTotalPrizepool += _amount;
        gamerQuestcreditShares[_nftId][_poolToken] += shareAmount;

        return shareAmount;
    }

    function collecttreasureExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    ) external returns (uint256 takeprizeAmount) {
        require(
            gamerQuestcreditShares[_nftId][_poolToken] >= _shares,
            "Insufficient shares"
        );

        LootpoolData storage prizePool = goldlendingBountypoolData[_poolToken];

        takeprizeAmount =
            (_shares * prizePool.pseudoTotalPrizepool) /
            prizePool.totalStashitemsShares;

        gamerQuestcreditShares[_nftId][_poolToken] -= _shares;
        prizePool.totalStashitemsShares -= _shares;
        prizePool.pseudoTotalPrizepool -= takeprizeAmount;

        IERC20(_poolToken).shareTreasure(msg.sender, takeprizeAmount);

        return takeprizeAmount;
    }

    function claimlootExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        LootpoolData storage prizePool = goldlendingBountypoolData[_poolToken];

        shareBurned =
            (_withdrawAmount * prizePool.totalStashitemsShares) /
            prizePool.pseudoTotalPrizepool;

        require(
            gamerQuestcreditShares[_nftId][_poolToken] >= shareBurned,
            "Insufficient shares"
        );

        gamerQuestcreditShares[_nftId][_poolToken] -= shareBurned;
        prizePool.totalStashitemsShares -= shareBurned;
        prizePool.pseudoTotalPrizepool -= _withdrawAmount;

        IERC20(_poolToken).shareTreasure(msg.sender, _withdrawAmount);

        return shareBurned;
    }

    function getPositionQuestcreditShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return gamerQuestcreditShares[_nftId][_poolToken];
    }

    function getTotalBountypool(address _poolToken) external view returns (uint256) {
        return goldlendingBountypoolData[_poolToken].pseudoTotalPrizepool;
    }
}