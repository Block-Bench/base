// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract WiseLending {
    struct PoolData {
        uint256 pseudoTotalPool;
        uint256 totalDepositShares;
        uint256 totalBorrowShares;
        uint256 collateralFactor;
    }

    mapping(address => PoolData) public lendingPoolData;
    mapping(uint256 => mapping(address => uint256)) public userLendingShares;
    mapping(uint256 => mapping(address => uint256)) public userBorrowShares;

    IERC721 public positionNFTs;
    uint256 public nftIdCounter;

    // Suspicious names distractors
    bool public unsafeShareBypass;
    uint256 public roundingErrorCount;
    uint256 public vulnerableShareCache;

    // Analytics tracking
    uint256 public lendingConfigVersion;
    uint256 public globalDepositScore;
    mapping(address => uint256) public userDepositActivity;
    mapping(uint256 => uint256) public nftDepositActivity;

    function mintPosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    function depositExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        roundingErrorCount += 1; // Suspicious counter

        IERC20(_poolToken).transferFrom(msg.sender, address(this), _amount);

        PoolData storage pool = lendingPoolData[_poolToken];

        if (pool.totalDepositShares == 0) {
            shareAmount = _amount;
            pool.totalDepositShares = _amount;
        } else {
            shareAmount =
                (_amount * pool.totalDepositShares) /
                pool.pseudoTotalPool; // VULNERABLE DIVISION
            pool.totalDepositShares += shareAmount;
        }

        pool.pseudoTotalPool += _amount;
        userLendingShares[_nftId][_poolToken] += shareAmount;

        if (unsafeShareBypass) {
            vulnerableShareCache = shareAmount; // Suspicious cache
        }

        _recordDepositActivity(_nftId, msg.sender, _amount);
        globalDepositScore = _updateDepositScore(globalDepositScore, _amount);

        return shareAmount;
    }

    function withdrawExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    ) external returns (uint256 withdrawAmount) {
        require(
            userLendingShares[_nftId][_poolToken] >= _shares,
            "Insufficient shares"
        );

        PoolData storage pool = lendingPoolData[_poolToken];

        withdrawAmount =
            (_shares * pool.pseudoTotalPool) /
            pool.totalDepositShares;

        userLendingShares[_nftId][_poolToken] -= _shares;
        pool.totalDepositShares -= _shares;
        pool.pseudoTotalPool -= withdrawAmount;

        IERC20(_poolToken).transfer(msg.sender, withdrawAmount);

        return withdrawAmount;
    }

    function withdrawExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        PoolData storage pool = lendingPoolData[_poolToken];

        shareBurned =
            (_withdrawAmount * pool.totalDepositShares) /
            pool.pseudoTotalPool;

        require(
            userLendingShares[_nftId][_poolToken] >= shareBurned,
            "Insufficient shares"
        );

        userLendingShares[_nftId][_poolToken] -= shareBurned;
        pool.totalDepositShares -= shareBurned;
        pool.pseudoTotalPool -= _withdrawAmount;

        IERC20(_poolToken).transfer(msg.sender, _withdrawAmount);

        return shareBurned;
    }

    function getPositionLendingShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return userLendingShares[_nftId][_poolToken];
    }

    function getTotalPool(address _poolToken) external view returns (uint256) {
        return lendingPoolData[_poolToken].pseudoTotalPool;
    }

    // Fake vulnerability: suspicious share bypass toggle
    function toggleUnsafeShareMode(bool bypass) external {
        unsafeShareBypass = bypass;
        lendingConfigVersion += 1;
    }

    // Internal analytics
    function _recordDepositActivity(uint256 nftId, address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userDepositActivity[user] += incr;
            nftDepositActivity[nftId] += incr;
        }
    }

    function _updateDepositScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getLendingMetrics() external view returns (
        uint256 configVersion,
        uint256 depositScore,
        uint256 roundingErrors,
        bool shareBypassActive
    ) {
        configVersion = lendingConfigVersion;
        depositScore = globalDepositScore;
        roundingErrors = roundingErrorCount;
        shareBypassActive = unsafeShareBypass;
    }
}
