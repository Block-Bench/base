// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**

 * Loss: $19.3 million

 *

 * causing the oracle to report incorrect prices, then borrowing against inflated collateral.
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

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface IStablePool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function balances(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract LendingPool is ILendingPool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    /**
     * @notice Deposit collateral into pool
     */
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;
    }

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {

        uint256 collateralPrice = oracle.getAssetPrice(msg.sender);
        uint256 borrowPrice = oracle.getAssetPrice(asset);

        // No validation if price has changed dramatically
        // No circuit breaker for unusual price movements

        uint256 collateralValue = (deposits[msg.sender] * collateralPrice) /
            1e18;
        uint256 maxBorrow = (collateralValue * LTV) / BASIS_POINTS;

        uint256 borrowValue = (amount * borrowPrice) / 1e18;

        require(borrowValue <= maxBorrow, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).transfer(onBehalfOf, amount);
    }

    /**
     * @notice Withdraw collateral
     */
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).transfer(to, amount);
        return amount;
    }
}

contract PoolOracle {
    IStablePool public stablePool;

    constructor(address _pool) {
        stablePool = _pool;
    }

    /**

     */
    function getAssetPrice(address asset) external view returns (uint256) {

        // No TWAP (Time-Weighted Average Price)
        // No external price validation

        uint256 balance0 = stablePool.balances(0);
        uint256 balance1 = stablePool.balances(1);

        // Easily manipulated by large swaps or liquidity removal
        uint256 price = (balance1 * 1e18) / balance0;

        return price;
    }
}

