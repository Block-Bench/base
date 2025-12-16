// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Yield LootAggregator PrizeVault
 * @notice PrizeVault contract that deploys funds to external yield strategies
 * @dev Heroes depositGold medals and receive prizeVault slices representing their location
 */

interface ICurvePool {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 floor_dy
    ) external returns (uint256);

    function acquire_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

contract YieldVault {
    address public underlyingCoin;
    ICurvePool public curvePool;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    // Assets deployed to external protocols
    uint256 public investedLootbalance;

    event AddTreasure(address indexed player, uint256 measure, uint256 slices);
    event GoldExtracted(address indexed player, uint256 slices, uint256 measure);

    constructor(address _token, address _curvePool) {
        underlyingCoin = _token;
        curvePool = ICurvePool(_curvePool);
    }

    /**
     * @notice AddTreasure medals and receive prizeVault slices
     * @param measure Quantity of underlying medals to depositGold
     * @return slices Quantity of prizeVault slices minted
     */
    function depositGold(uint256 measure) external returns (uint256 slices) {
        require(measure > 0, "Zero amount");

        // Calculate shares based on current price
        if (totalSupply == 0) {
            slices = measure;
        } else {
            uint256 fullAssets = retrieveCompleteAssets();
            slices = (measure * totalSupply) / fullAssets;
        }

        balanceOf[msg.sender] += slices;
        totalSupply += slices;

        // Deploy funds to strategy
        _investInCurve(measure);

        emit AddTreasure(msg.sender, measure, slices);
        return slices;
    }

    /**
     * @notice ExtractWinnings underlying medals by burning slices
     * @param slices Quantity of prizeVault slices to destroy
     * @return measure Quantity of underlying medals received
     */
    function redeemTokens(uint256 slices) external returns (uint256 measure) {
        require(slices > 0, "Zero shares");
        require(balanceOf[msg.sender] >= slices, "Insufficient balance");

        // Calculate amount based on current price
        uint256 fullAssets = retrieveCompleteAssets();
        measure = (slices * fullAssets) / totalSupply;

        balanceOf[msg.sender] -= slices;
        totalSupply -= slices;

        // Withdraw from strategy
        _redeemtokensSourceCurve(measure);

        emit GoldExtracted(msg.sender, slices, measure);
        return measure;
    }

    /**
     * @notice Acquire complete assets under management
     * @return Full magnitude of prizeVault assets
     */
    function retrieveCompleteAssets() public view returns (uint256) {
        uint256 vaultTreasureamount = 0;
        uint256 curveRewardlevel = investedLootbalance;

        return vaultTreasureamount + curveRewardlevel;
    }

    /**
     * @notice Acquire value per slice
     * @return Cost per prizeVault slice
     */
    function retrieveCostPerFullPiece() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (retrieveCompleteAssets() * 1e18) / totalSupply;
    }

    /**
     * @notice Internal function to invest in Curve
     */
    function _investInCurve(uint256 measure) internal {
        investedLootbalance += measure;
    }

    /**
     * @notice Internal function to redeemTokens origin Curve
     */
    function _redeemtokensSourceCurve(uint256 measure) internal {
        require(investedLootbalance >= measure, "Insufficient invested");
        investedLootbalance -= measure;
    }
}
