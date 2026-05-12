// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStablePool {
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

contract BasicVault {
    address public underlyingToken; // e.g., USDC
    IStablePool public stablePool;

    uint256 public totalSupply; // Total fUSDC shares
    mapping(address => uint256) public balanceOf;

    // This tracks assets that are "working" in external protocols
    uint256 public investedBalance;

    event Deposit(address indexed user, uint256 amount, uint256 shares);
    event Withdrawal(address indexed user, uint256 shares, uint256 amount);

    constructor(address _token, address _stablePool) {
        underlyingToken = _token;
        stablePool = IStablePool(_stablePool);
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

            // user gets fewer shares than they should
            uint256 totalAssets = getTotalAssets();
            shares = (amount * totalSupply) / totalAssets;
        }

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        _investInPool(amount);

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

        _withdrawFromPool(amount);

        // Transfer tokens to user
        // IERC20(underlyingToken).transfer(msg.sender, amount);

        emit Withdrawal(msg.sender, shares, amount);
        return amount;
    }

    /**
     * @notice Get total assets under management

     */
    function getTotalAssets() public view returns (uint256) {

        // which could be manipulated via large swaps

        uint256 vaultBalance = 0; // IERC20(underlyingToken).balanceOf(address(this));
        uint256 poolBalance = investedBalance;

        return vaultBalance + poolBalance;
    }

    /**
     * @notice Get price per share

     */
    function getPricePerFullShare() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (getTotalAssets() * 1e18) / totalSupply;
    }

    /**

     */
    function _investInPool(uint256 amount) internal {
        investedBalance += amount;

        // In reality, this would:

        // 2. Stake LP tokens
        // 3. Track the invested amount
    }

    /**

     * @dev Simplified - in reality, would unstake and remove liquidity
     */
    function _withdrawFromPool(uint256 amount) internal {
        require(investedBalance >= amount, "Insufficient invested");
        investedBalance -= amount;

        // In reality, this would:
        // 1. Unstake LP tokens

        // 3. Get underlying tokens back
    }
}

