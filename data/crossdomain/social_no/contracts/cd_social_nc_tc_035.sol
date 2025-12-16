pragma solidity ^0.8.0;

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function reputationOf(address creatorAccount) external view returns (uint256);

    function allowTip(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function passinfluenceFrom(address from, address to, uint256 socialtokenId) external;

    function adminOf(uint256 socialtokenId) external view returns (address);
}

contract WiseReputationadvance {
    struct TippoolData {
        uint256 pseudoTotalSupportpool;
        uint256 totalContributeShares;
        uint256 totalAskforbackingShares;
        uint256 guaranteeFactor;
    }

    mapping(address => TippoolData) public reputationadvanceDonationpoolData;
    mapping(uint256 => mapping(address => uint256)) public creatorReputationadvanceShares;
    mapping(uint256 => mapping(address => uint256)) public contributorAskforbackingShares;

    IERC721 public positionNFTs;
    uint256 public nftIdCounter;

    function earnkarmaPosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    function tipExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        IERC20(_poolToken).passinfluenceFrom(msg.sender, address(this), _amount);

        TippoolData storage fundingPool = reputationadvanceDonationpoolData[_poolToken];

        if (fundingPool.totalContributeShares == 0) {
            shareAmount = _amount;
            fundingPool.totalContributeShares = _amount;
        } else {
            shareAmount =
                (_amount * fundingPool.totalContributeShares) /
                fundingPool.pseudoTotalSupportpool;
            fundingPool.totalContributeShares += shareAmount;
        }

        fundingPool.pseudoTotalSupportpool += _amount;
        creatorReputationadvanceShares[_nftId][_poolToken] += shareAmount;

        return shareAmount;
    }

    function cashoutExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    ) external returns (uint256 cashoutAmount) {
        require(
            creatorReputationadvanceShares[_nftId][_poolToken] >= _shares,
            "Insufficient shares"
        );

        TippoolData storage fundingPool = reputationadvanceDonationpoolData[_poolToken];

        cashoutAmount =
            (_shares * fundingPool.pseudoTotalSupportpool) /
            fundingPool.totalContributeShares;

        creatorReputationadvanceShares[_nftId][_poolToken] -= _shares;
        fundingPool.totalContributeShares -= _shares;
        fundingPool.pseudoTotalSupportpool -= cashoutAmount;

        IERC20(_poolToken).passInfluence(msg.sender, cashoutAmount);

        return cashoutAmount;
    }

    function withdrawtipsExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        TippoolData storage fundingPool = reputationadvanceDonationpoolData[_poolToken];

        shareBurned =
            (_withdrawAmount * fundingPool.totalContributeShares) /
            fundingPool.pseudoTotalSupportpool;

        require(
            creatorReputationadvanceShares[_nftId][_poolToken] >= shareBurned,
            "Insufficient shares"
        );

        creatorReputationadvanceShares[_nftId][_poolToken] -= shareBurned;
        fundingPool.totalContributeShares -= shareBurned;
        fundingPool.pseudoTotalSupportpool -= _withdrawAmount;

        IERC20(_poolToken).passInfluence(msg.sender, _withdrawAmount);

        return shareBurned;
    }

    function getPositionReputationadvanceShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return creatorReputationadvanceShares[_nftId][_poolToken];
    }

    function getTotalTippool(address _poolToken) external view returns (uint256) {
        return reputationadvanceDonationpoolData[_poolToken].pseudoTotalSupportpool;
    }
}