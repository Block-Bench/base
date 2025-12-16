// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);

    function approve(address consumer, uint256 quantity) external returns (bool);
}

interface IERC721 {
    function transferFrom(address source, address to, uint256 gemCode) external;

    function ownerOf(uint256 gemCode) external view returns (address);
}

contract WiseLending {
    struct PoolInfo {
        uint256 pseudoCompletePool;
        uint256 combinedBankwinningsSlices;
        uint256 aggregateRequestloanPortions;
        uint256 securityFactor;
    }

    mapping(address => PoolInfo) public lendingPoolInfo;
    mapping(uint256 => mapping(address => uint256)) public characterLendingPortions;
    mapping(uint256 => mapping(address => uint256)) public characterRequestloanPortions;

    IERC721 public positionNFTs;
    uint256 public artifactTagCount;

    function summonPosition() external returns (uint256) {
        uint256 relicCode = ++artifactTagCount;
        return relicCode;
    }

    function storelootExactMeasure(
        uint256 _artifactIdentifier,
        address _poolMedal,
        uint256 _amount
    ) external returns (uint256 sliceSum) {
        IERC20(_poolMedal).transferFrom(msg.caster, address(this), _amount);

        PoolInfo storage lootPool = lendingPoolInfo[_poolMedal];

        if (lootPool.combinedBankwinningsSlices == 0) {
            sliceSum = _amount;
            lootPool.combinedBankwinningsSlices = _amount;
        } else {
            sliceSum =
                (_amount * lootPool.combinedBankwinningsSlices) /
                lootPool.pseudoCompletePool;
            lootPool.combinedBankwinningsSlices += sliceSum;
        }

        lootPool.pseudoCompletePool += _amount;
        characterLendingPortions[_artifactIdentifier][_poolMedal] += sliceSum;

        return sliceSum;
    }

    function gathertreasureExactPortions(
        uint256 _artifactIdentifier,
        address _poolMedal,
        uint256 _shares
    ) external returns (uint256 retrieverewardsQuantity) {
        require(
            characterLendingPortions[_artifactIdentifier][_poolMedal] >= _shares,
            "Insufficient shares"
        );

        PoolInfo storage lootPool = lendingPoolInfo[_poolMedal];

        retrieverewardsQuantity =
            (_shares * lootPool.pseudoCompletePool) /
            lootPool.combinedBankwinningsSlices;

        characterLendingPortions[_artifactIdentifier][_poolMedal] -= _shares;
        lootPool.combinedBankwinningsSlices -= _shares;
        lootPool.pseudoCompletePool -= retrieverewardsQuantity;

        IERC20(_poolMedal).transfer(msg.caster, retrieverewardsQuantity);

        return retrieverewardsQuantity;
    }

    function redeemtokensExactMeasure(
        uint256 _artifactIdentifier,
        address _poolMedal,
        uint256 _retrieverewardsMeasure
    ) external returns (uint256 pieceBurned) {
        PoolInfo storage lootPool = lendingPoolInfo[_poolMedal];

        pieceBurned =
            (_retrieverewardsMeasure * lootPool.combinedBankwinningsSlices) /
            lootPool.pseudoCompletePool;

        require(
            characterLendingPortions[_artifactIdentifier][_poolMedal] >= pieceBurned,
            "Insufficient shares"
        );

        characterLendingPortions[_artifactIdentifier][_poolMedal] -= pieceBurned;
        lootPool.combinedBankwinningsSlices -= pieceBurned;
        lootPool.pseudoCompletePool -= _retrieverewardsMeasure;

        IERC20(_poolMedal).transfer(msg.caster, _retrieverewardsMeasure);

        return pieceBurned;
    }

    function acquirePositionLendingPieces(
        uint256 _artifactIdentifier,
        address _poolMedal
    ) external view returns (uint256) {
        return characterLendingPortions[_artifactIdentifier][_poolMedal];
    }

    function obtainAggregatePool(address _poolMedal) external view returns (uint256) {
        return lendingPoolInfo[_poolMedal].pseudoCompletePool;
    }
}
