// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * INVERSE FINANCE EXPLOIT (April 2022)
 *
 * Attack Vector: Oracle Price Manipulation via Curve Pool
 * Loss: $15.6 million
 *
 * VULNERABILITY:
 * Inverse Finance used a Curve LP token as collateral (anYvCrv3Crypto).
 * The oracle for pricing this token relied on Curve pool reserves which
 * could be manipulated via flash loans within a single transaction.
 *
 * By adding massive liquidity to the Curve pool, the attacker inflated
 * the LP token price reported by the oracle, then borrowed against the
 * overvalued collateral.
 *
 * Attack Steps:
 * 1. Flash loan WBTC from Aave
 * 2. Add liquidity to Curve 3crypto pool (USDT/WBTC/WETH)
 * 3. Deposit Curve LP tokens to Yearn vault
 * 4. Deposit Yearn tokens as collateral in Inverse Finance
 * 5. Oracle reads inflated LP token price from manipulated pool
 * 6. Borrow maximum DOLA against inflated collateral
 * 7. Remove liquidity, repay flash loan
 * 8. Keep overborrowed DOLA
 */

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurvePool {
    function get_virtual_price() external view returns (uint256);

    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 minMintAmount
    ) external;
}

contract SimplifiedOracle {
    ICurvePool public curvePool;

    constructor(address _curvePool) {
        curvePool = ICurvePool(_curvePool);
    }

    /**
     * @notice VULNERABLE: Gets price directly from Curve pool
     * @dev This price can be manipulated via flash loan attacks
     */
    function getPrice() external view returns (uint256) {
        return curvePool.get_virtual_price();
    }
}

contract InverseLending {
    struct Position {
        uint256 collateral;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public collateralToken;
    address public borrowToken;
    address public oracle;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        collateralToken = _collateralToken;
        borrowToken = _borrowToken;
        oracle = _oracle;
    }

    /**
     * @notice Deposit collateral
     */
    function deposit(uint256 amount) external {
        IERC20(collateralToken).transferFrom(msg.sender, address(this), amount);
        positions[msg.sender].collateral += amount;
    }

    /**
     * @notice VULNERABLE: Borrow against collateral using manipulatable oracle
     */
    function borrow(uint256 amount) external {
        uint256 collateralValue = getCollateralValue(msg.sender);
        uint256 maxBorrow = (collateralValue * COLLATERAL_FACTOR) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxBorrow,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(borrowToken).transfer(msg.sender, amount);
    }

    /**
     * @notice Calculate collateral value using oracle price
     * @dev VULNERABLE: Oracle price can be manipulated
     */
    function getCollateralValue(address user) public view returns (uint256) {
        uint256 collateralAmount = positions[user].collateral;
        uint256 price = SimplifiedOracle(oracle).getPrice();

        return (collateralAmount * price) / 1e18;
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * Initial State:
 * - Curve 3crypto pool: 10M USDT, 500 WBTC, 5000 WETH (balanced)
 * - LP token virtual price: $1.00
 * - Attacker has 1000 yvCrv3Crypto tokens
 *
 * Attack:
 * 1. Flash loan 2700 WBTC from Aave
 *
 * 2. Add massive liquidity to Curve pool:
 *    - Deposit 2677.5 WBTC and 22,500 USDT
 *    - Pool now heavily imbalanced: 3177 WBTC, 10M USDT, 5000 WETH
 *
 * 3. Curve virtual_price calculation:
 *    - virtual_price = D / totalSupply
 *    - D (invariant) increases due to added liquidity
 *    - virtual_price inflates from $1.00 to ~$1.50
 *
 * 4. Deposit yvCrv3Crypto as collateral:
 *    - Oracle reads inflated virtual_price ($1.50)
 *    - 1000 tokens * $1.50 = $1,500 collateral value
 *    - True value should be $1,000
 *
 * 5. Borrow maximum DOLA:
 *    - maxBorrow = $1,500 * 80% = $1,200
 *    - Should only be able to borrow $800
 *    - Overborrowed $400 per 1000 tokens
 *
 * 6. Swap borrowed DOLA to stablecoins
 *
 * 7. Remove liquidity from Curve:
 *    - Pool rebalances
 *    - virtual_price returns to normal
 *    - But borrowing already completed!
 *
 * 8. Repay flash loan
 *
 * 9. Profit: $15.6M in overborrowed funds
 *
 * Root Cause:
 * - Oracle relied on Curve's get_virtual_price()
 * - virtual_price is based on current pool state
 * - Adding liquidity inflates the virtual price within one transaction
 * - No TWAP or manipulation resistance
 *
 * Fix:
 * - Use time-weighted average oracle prices
 * - Implement EMA (Exponential Moving Average) for price feeds
 * - Add minimum time delays between price updates
 * - Use multiple oracle sources (Chainlink + internal)
 * - Implement manipulation-resistant LP token valuation
 */
