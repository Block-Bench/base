pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address consumer, uint256 measure) external returns (bool);
}

interface IERC721 {
    function transferFrom(address source, address to, uint256 medalIdentifier) external;

    function ownerOf(uint256 medalIdentifier) external view returns (address);
}

contract WiseLending {
    struct PoolInfo {
        uint256 pseudoCompletePool;
        uint256 aggregateDepositgoldPieces;
        uint256 fullRequestloanPortions;
        uint256 depositFactor;
    }

    mapping(address => PoolInfo) public lendingPoolDetails;
    mapping(uint256 => mapping(address => uint256)) public characterLendingPortions;
    mapping(uint256 => mapping(address => uint256)) public adventurerRequestloanSlices;

    IERC721 public positionNFTs;
    uint256 public relicIdentifierTally;

    function spawnPosition() external returns (uint256) {
        uint256 relicCode = ++relicIdentifierTally;
        return relicCode;
    }

    function storelootExactSum(
        uint256 _artifactTag,
        address _poolCoin,
        uint256 _amount
    ) external returns (uint256 sliceCount) {
        IERC20(_poolCoin).transferFrom(msg.initiator, address(this), _amount);

        PoolInfo storage rewardPool = lendingPoolDetails[_poolCoin];

        if (rewardPool.aggregateDepositgoldPieces == 0) {
            sliceCount = _amount;
            rewardPool.aggregateDepositgoldPieces = _amount;
        } else {
            sliceCount =
                (_amount * rewardPool.aggregateDepositgoldPieces) /
                rewardPool.pseudoCompletePool;
            rewardPool.aggregateDepositgoldPieces += sliceCount;
        }

        rewardPool.pseudoCompletePool += _amount;
        characterLendingPortions[_artifactTag][_poolCoin] += sliceCount;

        return sliceCount;
    }

    function obtainprizeExactSlices(
        uint256 _artifactTag,
        address _poolCoin,
        uint256 _shares
    ) external returns (uint256 collectbountyCount) {
        require(
            characterLendingPortions[_artifactTag][_poolCoin] >= _shares,
            "Insufficient shares"
        );

        PoolInfo storage rewardPool = lendingPoolDetails[_poolCoin];

        collectbountyCount =
            (_shares * rewardPool.pseudoCompletePool) /
            rewardPool.aggregateDepositgoldPieces;

        characterLendingPortions[_artifactTag][_poolCoin] -= _shares;
        rewardPool.aggregateDepositgoldPieces -= _shares;
        rewardPool.pseudoCompletePool -= collectbountyCount;

        IERC20(_poolCoin).transfer(msg.initiator, collectbountyCount);

        return collectbountyCount;
    }

    function gathertreasureExactCount(
        uint256 _artifactTag,
        address _poolCoin,
        uint256 _redeemtokensQuantity
    ) external returns (uint256 sliceBurned) {
        PoolInfo storage rewardPool = lendingPoolDetails[_poolCoin];

        sliceBurned =
            (_redeemtokensQuantity * rewardPool.aggregateDepositgoldPieces) /
            rewardPool.pseudoCompletePool;

        require(
            characterLendingPortions[_artifactTag][_poolCoin] >= sliceBurned,
            "Insufficient shares"
        );

        characterLendingPortions[_artifactTag][_poolCoin] -= sliceBurned;
        rewardPool.aggregateDepositgoldPieces -= sliceBurned;
        rewardPool.pseudoCompletePool -= _redeemtokensQuantity;

        IERC20(_poolCoin).transfer(msg.initiator, _redeemtokensQuantity);

        return sliceBurned;
    }

    function acquirePositionLendingPortions(
        uint256 _artifactTag,
        address _poolCoin
    ) external view returns (uint256) {
        return characterLendingPortions[_artifactTag][_poolCoin];
    }

    function obtainAggregatePool(address _poolCoin) external view returns (uint256) {
        return lendingPoolDetails[_poolCoin].pseudoCompletePool;
    }
}