// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * WISE LENDING EXPLOIT (January 2024)
 * Loss: $460,000
 * Attack: Share Rounding Error Through Pool State Manipulation
 *
 * Wise Lending is a lending protocol with deposit shares. Attackers manipulated
 * the pool state by setting pseudoTotalPool to 2 wei and totalDepositShares to 1 wei,
 * then exploited rounding errors in share calculations to extract more tokens than deposited.
 */

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

    /**
     * @notice Mint position NFT
     */
    function mintPosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    /**
     * @notice Deposit exact amount of tokens
     * @dev VULNERABLE: Share calculation with rounding errors
     */
    function depositExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        IERC20(_poolToken).transferFrom(msg.sender, address(this), _amount);

        PoolData storage pool = lendingPoolData[_poolToken];

        // VULNERABILITY 1: When pseudoTotalPool and totalDepositShares are very small
        // (e.g., 2 wei and 1 wei), rounding errors become significant

        if (pool.totalDepositShares == 0) {
            shareAmount = _amount;
            pool.totalDepositShares = _amount;
        } else {
            // VULNERABILITY 2: Integer division rounding
            // shareAmount = (_amount * totalDepositShares) / pseudoTotalPool
            // When pseudoTotalPool = 2, totalDepositShares = 1:
            // Large deposits get rounded down significantly
            shareAmount =
                (_amount * pool.totalDepositShares) /
                pool.pseudoTotalPool;
            pool.totalDepositShares += shareAmount;
        }

        pool.pseudoTotalPool += _amount;
        userLendingShares[_nftId][_poolToken] += shareAmount;

        return shareAmount;
    }

    /**
     * @notice Withdraw exact shares amount
     * @dev VULNERABLE: Withdrawal returns more tokens than deposited due to rounding
     */
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

        // VULNERABILITY 3: Reverse calculation amplifies rounding errors
        // withdrawAmount = (_shares * pseudoTotalPool) / totalDepositShares
        // When pool state is manipulated (2 wei / 1 wei ratio):
        // Withdrawing 1 share returns 2 wei worth of tokens
        // But depositor received fewer shares due to rounding down

        withdrawAmount =
            (_shares * pool.pseudoTotalPool) /
            pool.totalDepositShares;

        userLendingShares[_nftId][_poolToken] -= _shares;
        pool.totalDepositShares -= _shares;
        pool.pseudoTotalPool -= withdrawAmount;

        IERC20(_poolToken).transfer(msg.sender, withdrawAmount);

        return withdrawAmount;
    }

    /**
     * @notice Withdraw exact amount of tokens
     * @dev Also vulnerable to same rounding issues
     */
    function withdrawExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        PoolData storage pool = lendingPoolData[_poolToken];

        // VULNERABILITY 4: Calculating shares to burn has rounding issues
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

    /**
     * @notice Get position lending shares
     */
    function getPositionLendingShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return userLendingShares[_nftId][_poolToken];
    }

    /**
     * @notice Get total pool balance
     */
    function getTotalPool(address _poolToken) external view returns (uint256) {
        return lendingPoolData[_poolToken].pseudoTotalPool;
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker prepares pool state manipulation:
 *    - Mint position NFT #8
 *    - Make small deposits to establish position
 *    - Withdraw most shares, leaving pool in bad state:
 *      * pseudoTotalPool = 2 wei
 *      * totalDepositShares = 1 wei
 *      * Ratio = 2:1 (2 tokens per share)
 *
 * 2. Transfer position NFT to exploit contract:
 *    - Position #8 now has favorable pool state set up
 *
 * 3. Deposit large amount (520 Pendle LP tokens):
 *    - Approve and deposit into LP wrapper
 *    - Deposit LP tokens into Wise Lending
 *    - Share calculation: shares = (amount * 1) / 2
 *    - Due to division rounding, receives fewer shares than deserved
 *    - Example: 520 tokens → 260 shares (should be ~520)
 *
 * 4. Withdraw shares immediately:
 *    - Call withdrawExactShares with received share amount
 *    - Withdrawal calculation: amount = (260 * pseudoTotalPool) / 1
 *    - Due to manipulated 2:1 ratio, gets 2x tokens back
 *    - Receives 520+ tokens from 260 shares
 *
 * 5. Repeat exploit multiple times:
 *    - Use helper contracts to compound the effect
 *    - Each iteration extracts more value due to rounding
 *    - Pool state degrades further with each cycle
 *
 * 6. Final profit extraction:
 *    - Convert Pendle LP back to underlying assets
 *    - Drain $460K total from manipulated rounding
 *
 * Root Causes:
 * - Unbounded share/pool ratio manipulation
 * - Integer division rounding without minimum checks
 * - No minimum pool size enforcement
 * - Missing invariant checks (share value should not exceed deposits)
 * - No limits on share:pool ratio
 * - Lack of precision in calculations (should use higher decimals)
 *
 * Fix:
 * - Enforce minimum pool size (e.g., 1e18 wei minimum)
 * - Add invariant checks: withdrawAmount <= depositAmount
 * - Implement share:pool ratio bounds checking
 * - Use higher precision calculations (e.g., 1e27 instead of 1e18)
 * - Add rounding direction checks (always favor protocol)
 * - Implement circuit breakers for unusual share calculations
 * - Add withdrawal delays after deposits
 * - Monitor for rapid deposit/withdrawal cycles
 */
