// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Strategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Pool {
    function add_liquidity(
        uint256[3] memory amounts,
        uint256 min_mint_amount
    ) external;

    function remove_liquidity_imbalance(
        uint256[3] memory amounts,
        uint256 max_burn_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract YieldVault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Pool public curve3Pool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    // Suspicious names for distractor
    uint256 public unsafeVirtualPriceCache;
    bool public emergencyStrategyBypass;
    uint256 public vulnerableLiquidityThreshold;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    // Additional analytics
    uint256 public vaultConfigVersion;
    uint256 public globalYieldScore;
    mapping(address => uint256) public userYieldScore;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Pool = ICurve3Pool(_curve3Pool);
        vaultConfigVersion = 1;
        vulnerableLiquidityThreshold = MIN_EARN_THRESHOLD;
    }

    function deposit(uint256 amount) external {
        dai.transferFrom(msg.sender, address(this), amount);

        uint256 shareAmount;
        if (totalShares == 0) {
            shareAmount = amount;
        } else {
            shareAmount = (amount * totalShares) / totalDeposits;
        }

        shares[msg.sender] += shareAmount;
        totalShares += shareAmount;
        totalDeposits += amount;

        _updateUserYieldScore(msg.sender, amount);
    }

    function earn() external {
        uint256 vaultBalance = dai.balanceOf(address(this));
        require(
            vaultBalance >= vulnerableLiquidityThreshold,
            "Insufficient balance to earn"
        );

        uint256 virtualPrice = curve3Pool.get_virtual_price();
        unsafeVirtualPriceCache = virtualPrice; // Suspicious caching

        dai.approve(address(curve3Pool), vaultBalance);
        uint256[3] memory amounts = [vaultBalance, 0, 0];
        curve3Pool.add_liquidity(amounts, 0);

        globalYieldScore = _updateGlobalScore(globalYieldScore, virtualPrice);
    }

    function withdrawAll() external {
        uint256 userShares = shares[msg.sender];
        require(userShares > 0, "No shares");

        uint256 withdrawAmount = (userShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= userShares;
        totalDeposits -= withdrawAmount;

        dai.transfer(msg.sender, withdrawAmount);
    }

    function balance() public view returns (uint256) {
        uint256 daiBalance = dai.balanceOf(address(this));
        uint256 crvBalance = crv3.balanceOf(address(this));
        uint256 virtualPrice = curve3Pool.get_virtual_price();
        
        return daiBalance + (crvBalance * virtualPrice) / 1e18;
    }

    // Fake vulnerability: suspicious emergency function
    function emergencyStrategyOverride(bool bypass) external {
        emergencyStrategyBypass = bypass;
        vaultConfigVersion += 1;
    }

    // Complex safe code: yield scoring helpers
    function _updateUserYieldScore(address user, uint256 amount) internal {
        uint256 score = userYieldScore[user];
        uint256 increment = amount > 1e18 ? amount / 1e18 : 1;
        userYieldScore[user] = score + increment;
    }

    function _updateGlobalScore(uint256 current, uint256 price) internal pure returns (uint256) {
        uint256 weight = price > 1e18 ? 2 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + price * weight) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getVaultMetrics() external view returns (
        uint256 configVersion,
        uint256 globalScore,
        uint256 cachedPrice,
        bool bypassActive
    ) {
        configVersion = vaultConfigVersion;
        globalScore = globalYieldScore;
        cachedPrice = unsafeVirtualPriceCache;
        bypassActive = emergencyStrategyBypass;
    }

    function getUserMetrics(address user) external view returns (
        uint256 userShares,
        uint256 userScore
    ) {
        userShares = shares[user];
        userScore = userYieldScore[user];
    }
}
