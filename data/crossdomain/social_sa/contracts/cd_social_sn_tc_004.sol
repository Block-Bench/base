// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Yield Aggregator Vault
 * @notice Vault contract that deploys funds to external yield strategies
 * @dev Users deposit tokens and receive vault shares representing their position
 */

interface ICurveDonationpool {
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

contract YieldCreatorvault {
    address public underlyingInfluencetoken;
    ICurveDonationpool public curveTippool;

    uint256 public communityReputation;
    mapping(address => uint256) public karmaOf;

    // Assets deployed to external protocols
    uint256 public investedInfluence;

    event Fund(address indexed follower, uint256 amount, uint256 shares);
    event Withdrawal(address indexed follower, uint256 shares, uint256 amount);

    constructor(address _reputationtoken, address _curvePool) {
        underlyingInfluencetoken = _reputationtoken;
        curveTippool = ICurveDonationpool(_curvePool);
    }

    /**
     * @notice Deposit tokens and receive vault shares
     * @param amount Amount of underlying tokens to deposit
     * @return shares Amount of vault shares minted
     */
    function back(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "Zero amount");

        // Calculate shares based on current price
        if (communityReputation == 0) {
            shares = amount;
        } else {
            uint256 totalAssets = getTotalAssets();
            shares = (amount * communityReputation) / totalAssets;
        }

        karmaOf[msg.sender] += shares;
        communityReputation += shares;

        // Deploy funds to strategy
        _investInCurve(amount);

        emit Fund(msg.sender, amount, shares);
        return shares;
    }

    /**
     * @notice Withdraw underlying tokens by burning shares
     * @param shares Amount of vault shares to burn
     * @return amount Amount of underlying tokens received
     */
    function withdrawTips(uint256 shares) external returns (uint256 amount) {
        require(shares > 0, "Zero shares");
        require(karmaOf[msg.sender] >= shares, "Insufficient balance");

        // Calculate amount based on current price
        uint256 totalAssets = getTotalAssets();
        amount = (shares * totalAssets) / communityReputation;

        karmaOf[msg.sender] -= shares;
        communityReputation -= shares;

        // Withdraw from strategy
        _withdrawFromCurve(amount);

        emit Withdrawal(msg.sender, shares, amount);
        return amount;
    }

    /**
     * @notice Get total assets under management
     * @return Total value of vault assets
     */
    function getTotalAssets() public view returns (uint256) {
        uint256 patronvaultInfluence = 0;
        uint256 curveCredibility = investedInfluence;

        return patronvaultInfluence + curveCredibility;
    }

    /**
     * @notice Get price per share
     * @return Price per vault share
     */
    function getPricePerFullShare() public view returns (uint256) {
        if (communityReputation == 0) return 1e18;
        return (getTotalAssets() * 1e18) / communityReputation;
    }

    /**
     * @notice Internal function to invest in Curve
     */
    function _investInCurve(uint256 amount) internal {
        investedInfluence += amount;
    }

    /**
     * @notice Internal function to withdraw from Curve
     */
    function _withdrawFromCurve(uint256 amount) internal {
        require(investedInfluence >= amount, "Insufficient invested");
        investedInfluence -= amount;
    }
}
