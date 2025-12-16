// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function reputationOf(address profile) external view returns (uint256);

    function authorizeGift(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function sendtipFrom(address from, address to, uint256 karmatokenId) external;

    function communityleadOf(uint256 karmatokenId) external view returns (address);
}

contract WiseKarmaloan {
    struct SupportpoolData {
        uint256 pseudoTotalFundingpool;
        uint256 totalContributeShares;
        uint256 totalSeekfundingShares;
        uint256 pledgeFactor;
    }

    mapping(address => SupportpoolData) public reputationadvanceSupportpoolData;
    mapping(uint256 => mapping(address => uint256)) public contributorReputationadvanceShares;
    mapping(uint256 => mapping(address => uint256)) public memberAskforbackingShares;

    IERC721 public positionNFTs;
    uint256 public nftIdCounter;

    function gainreputationPosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    function contributeExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        IERC20(_poolToken).sendtipFrom(msg.sender, address(this), _amount);

        SupportpoolData storage fundingPool = reputationadvanceSupportpoolData[_poolToken];

        if (fundingPool.totalContributeShares == 0) {
            shareAmount = _amount;
            fundingPool.totalContributeShares = _amount;
        } else {
            shareAmount =
                (_amount * fundingPool.totalContributeShares) /
                fundingPool.pseudoTotalFundingpool;
            fundingPool.totalContributeShares += shareAmount;
        }

        fundingPool.pseudoTotalFundingpool += _amount;
        contributorReputationadvanceShares[_nftId][_poolToken] += shareAmount;

        return shareAmount;
    }

    function claimearningsExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    ) external returns (uint256 collectAmount) {
        require(
            contributorReputationadvanceShares[_nftId][_poolToken] >= _shares,
            "Insufficient shares"
        );

        SupportpoolData storage fundingPool = reputationadvanceSupportpoolData[_poolToken];

        collectAmount =
            (_shares * fundingPool.pseudoTotalFundingpool) /
            fundingPool.totalContributeShares;

        contributorReputationadvanceShares[_nftId][_poolToken] -= _shares;
        fundingPool.totalContributeShares -= _shares;
        fundingPool.pseudoTotalFundingpool -= collectAmount;

        IERC20(_poolToken).passInfluence(msg.sender, collectAmount);

        return collectAmount;
    }

    function collectExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        SupportpoolData storage fundingPool = reputationadvanceSupportpoolData[_poolToken];

        shareBurned =
            (_withdrawAmount * fundingPool.totalContributeShares) /
            fundingPool.pseudoTotalFundingpool;

        require(
            contributorReputationadvanceShares[_nftId][_poolToken] >= shareBurned,
            "Insufficient shares"
        );

        contributorReputationadvanceShares[_nftId][_poolToken] -= shareBurned;
        fundingPool.totalContributeShares -= shareBurned;
        fundingPool.pseudoTotalFundingpool -= _withdrawAmount;

        IERC20(_poolToken).passInfluence(msg.sender, _withdrawAmount);

        return shareBurned;
    }

    function getPositionSocialcreditShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return contributorReputationadvanceShares[_nftId][_poolToken];
    }

    function getTotalFundingpool(address _poolToken) external view returns (uint256) {
        return reputationadvanceSupportpoolData[_poolToken].pseudoTotalFundingpool;
    }
}
