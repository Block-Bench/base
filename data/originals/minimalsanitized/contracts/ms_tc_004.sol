// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract HarvestVault {
    address public underlyingToken; // e.g., USDC
    ICurvePool public curvePool;

    uint256 public totalSupply; // Total fUSDC shares
    mapping(address => uint256) public balanceOf;

    // This tracks assets that are "working" in external protocols
    uint256 public investedBalance;

    event Deposit(address indexed user, uint256 amount, uint256 shares);
    event Withdrawal(address indexed user, uint256 shares, uint256 amount);

    constructor(address _token, address _curvePool) {
        underlyingToken = _token;
        curvePool = ICurvePool(_curvePool);
    }

    function deposit(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "Zero amount");

        // Transfer tokens from user
        // IERC20(underlyingToken).transferFrom(msg.sender, address(this), amount);

        // Calculate shares based on current price
        if (totalSupply == 0) {
            shares = amount;
        } else {
            // shares = amount * totalSupply / totalAssets()
            // If totalAssets() is artificially inflated via Curve manipulation,
            // user gets fewer shares than they should
            uint256 totalAssets = getTotalAssets();
            shares = (amount * totalSupply) / totalAssets;
        }

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        // Strategy: Deploy funds to Curve for yield
        _investInCurve(amount);

        emit Deposit(msg.sender, amount, shares);
        return shares;
    }

    function withdraw(uint256 shares) external returns (uint256 amount) {
        require(shares > 0, "Zero shares");
        require(balanceOf[msg.sender] >= shares, "Insufficient balance");

        // Calculate amount based on current price
        uint256 totalAssets = getTotalAssets();
        amount = (shares * totalAssets) / totalSupply;

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        // Withdraw from Curve strategy if needed
        _withdrawFromCurve(amount);

        // Transfer tokens to user
        // IERC20(underlyingToken).transfer(msg.sender, amount);

        emit Withdrawal(msg.sender, shares, amount);
        return amount;
    }

    function getTotalAssets() public view returns (uint256) {
        // Assets in vault + assets in Curve
        // In reality, Harvest calculated this including Curve pool values
        // which could be manipulated via large swaps

        uint256 vaultBalance = 0; // IERC20(underlyingToken).balanceOf(address(this));
        uint256 curveBalance = investedBalance;

        // the Curve pool's exchange rates
        return vaultBalance + curveBalance;
    }

    function getPricePerFullShare() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (getTotalAssets() * 1e18) / totalSupply;
    }

    /**
     * @notice Internal function to invest in Curve
     * @dev Simplified - in reality, Harvest used Curve pools for yield
     */
    function _investInCurve(uint256 amount) internal {
        investedBalance += amount;

        // In reality, this would:
        // 1. Add liquidity to Curve pool
        // 2. Stake LP tokens
        // 3. Track the invested amount
    }

    /**
     * @notice Internal function to withdraw from Curve
     * @dev Simplified - in reality, would unstake and remove liquidity
     */
    function _withdrawFromCurve(uint256 amount) internal {
        require(investedBalance >= amount, "Insufficient invested");
        investedBalance -= amount;

        // In reality, this would:
        // 1. Unstake LP tokens
        // 2. Remove liquidity from Curve
        // 3. Get underlying tokens back
    }
}
