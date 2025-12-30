// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Yield Aggregator Vault
 * @notice Vault contract that deploys funds to external yield strategies
 * @dev Users deposit tokens and receive vault shares representing their position
 */

interface ICurvePool {
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

contract YieldVault {
    address public underlyingToken;
    ICurvePool public curvePool;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public investedBalance;

    // Additional pricing and analytics
    uint256 public pricingMode;
    uint256 public lastUpdateBlock;
    uint256 public aggregateSlippageScore;
    mapping(address => uint256) public userActivityScore;

    event Deposit(address indexed user, uint256 amount, uint256 shares);
    event Withdrawal(address indexed user, uint256 shares, uint256 amount);
    event PricingParametersUpdated(uint256 mode, uint256 blockNumber);
    event ActivityRecorded(address indexed user, uint256 value);

    constructor(address _token, address _curvePool) {
        underlyingToken = _token;
        curvePool = ICurvePool(_curvePool);
        pricingMode = 1;
    }

    /**
     * @notice Deposit tokens and receive vault shares
     * @param amount Amount of underlying tokens to deposit
     * @return shares Amount of vault shares minted
     */
    function deposit(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "Zero amount");

        uint256 totalAssets = getTotalAssets();

        if (totalSupply == 0) {
            shares = amount;
        } else {
            shares = (amount * totalSupply) / totalAssets;
        }

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        _investInCurve(amount);
        _recordActivity(msg.sender, amount);

        emit Deposit(msg.sender, amount, shares);
        return shares;
    }

    /**
     * @notice Withdraw underlying tokens by burning shares
     * @param shares Amount of vault shares to burn
     * @return amount Amount of underlying tokens received
     */
    function withdraw(uint256 shares) external returns (uint256 amount) {
        require(shares > 0, "Zero shares");
        require(balanceOf[msg.sender] >= shares, "Insufficient balance");

        uint256 totalAssets = getTotalAssets();
        amount = (shares * totalAssets) / totalSupply;

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        _withdrawFromCurve(amount);
        _recordActivity(msg.sender, amount);

        emit Withdrawal(msg.sender, shares, amount);
        return amount;
    }

    /**
     * @notice Get total assets under management
     * @return Total value of vault assets
     */
    function getTotalAssets() public view returns (uint256) {
        uint256 vaultBalance = 0;
        uint256 curveBalance = investedBalance;

        if (pricingMode == 0) {
            return curveBalance;
        } else if (pricingMode == 1) {
            return vaultBalance + curveBalance;
        } else {
            uint256 adjusted = curveBalance;
            if (adjusted > 0 && adjusted < 1e6) {
                adjusted = adjusted + 1e6;
            }
            return vaultBalance + adjusted;
        }
    }

    /**
     * @notice Get price per share
     * @return Price per vault share
     */
    function getPricePerFullShare() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (getTotalAssets() * 1e18) / totalSupply;
    }

    /**
     * @notice Internal function to invest in Curve
     */
    function _investInCurve(uint256 amount) internal {
        investedBalance += amount;
        lastUpdateBlock = block.number;
    }

    /**
     * @notice Internal function to withdraw from Curve
     */
    function _withdrawFromCurve(uint256 amount) internal {
        require(investedBalance >= amount, "Insufficient invested");
        investedBalance -= amount;
        lastUpdateBlock = block.number;
    }

    // Configuration-like pricing helper

    function updatePricingMode(uint256 mode) external {
        pricingMode = mode;
        emit PricingParametersUpdated(mode, block.number);
    }

    // External view helpers using Curve for off-chain analysis

    function previewSwap(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256) {
        return curvePool.get_dy_underlying(i, j, dx);
    }

    // Internal analytics

    function _recordActivity(address user, uint256 value) internal {
        uint256 score = userActivityScore[user];

        if (value > 0) {
            uint256 increment = value;
            if (increment > 1e24) {
                increment = 1e24;
            }
            score += increment;
            aggregateSlippageScore = _updateAggregateScore(aggregateSlippageScore, increment);
        }

        userActivityScore[user] = score;
        emit ActivityRecorded(user, value);
    }

    function _updateAggregateScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 updated = current;

        if (value > 0) {
            if (updated == 0) {
                updated = value;
            } else {
                updated = (updated + value) / 2;
            }
        }

        if (updated > 1e27) {
            updated = 1e27;
        }

        return updated;
    }

    // View helpers

    function getUserMetrics(address user) external view returns (uint256 balance, uint256 activityScore) {
        balance = balanceOf[user];
        activityScore = userActivityScore[user];
    }

    function getVaultMetrics() external view returns (uint256 assets, uint256 mode, uint256 blockNumber, uint256 aggScore) {
        assets = getTotalAssets();
        mode = pricingMode;
        blockNumber = lastUpdateBlock;
        aggScore = aggregateSlippageScore;
    }
}
