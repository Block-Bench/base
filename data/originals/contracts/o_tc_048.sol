// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * SONNE FINANCE EXPLOIT (May 2024)
 * Loss: $20 million
 * Attack: Oracle Manipulation via Donation Attack on Empty Market
 *
 * VULNERABILITY OVERVIEW:
 * Sonne Finance, a Compound V2 fork on Optimism, was exploited through oracle manipulation.
 * Attacker created an empty lending market, donated collateral to manipulate exchange rate,
 * then used inflated collateral value to borrow assets from other markets.
 *
 * ROOT CAUSE:
 * 1. Exchange rate calculation vulnerable when totalSupply is very small
 * 2. Direct token donation could manipulate underlying/supply ratio
 * 3. No minimum liquidity requirement for new markets
 * 4. Missing sanity checks on exchange rate jumps
 *
 * ATTACK FLOW:
 * 1. Attacker supplied VELO tokens as collateral on Sonne
 * 2. Borrowed small amount from new soWETH market (low liquidity)
 * 3. Donated large amount of WETH directly to soWETH contract
 * 4. Exchange rate inflated: totalUnderlying/totalSupply became huge
 * 5. Redeemed minimal soWETH for massive WETH due to manipulated rate
 * 6. Used over-valued collateral to borrow from other markets
 * 7. Drained ~$20M in various assets
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

/**
 * Simplified model of Sonne Finance's vulnerable cToken (Compound V2 fork)
 */
contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    // Compound-style interest rate tracking
    uint256 public totalBorrows;
    uint256 public totalReserves;

    event Mint(address minter, uint256 mintAmount, uint256 mintTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    /**
     * @dev VULNERABILITY: Exchange rate calculation susceptible to donation attack
     * @dev When totalSupply is small, direct donations massively inflate rate
     */
    function exchangeRate() public view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18; // Initial exchange rate: 1:1
        }

        // VULNERABILITY 1: Uses balanceOf which includes donated tokens
        uint256 cash = underlying.balanceOf(address(this));

        // exchangeRate = (cash + totalBorrows - totalReserves) / totalSupply
        // VULNERABILITY 2: If totalSupply very small, rate easily manipulated
        uint256 totalUnderlying = cash + totalBorrows - totalReserves;

        // VULNERABILITY 3: No sanity check on rate changes
        // VULNERABILITY 4: Rate can jump 1000x in single block
        return (totalUnderlying * 1e18) / totalSupply;
    }

    /**
     * @dev Supply underlying tokens, receive cTokens
     */
    function mint(uint256 mintAmount) external returns (uint256) {
        require(mintAmount > 0, "Zero mint");

        uint256 exchangeRateMantissa = exchangeRate();

        // Calculate cTokens to mint: mintAmount * 1e18 / exchangeRate
        uint256 mintTokens = (mintAmount * 1e18) / exchangeRateMantissa;

        // VULNERABILITY 5: First depositor can manipulate by minting tiny amount
        // then donating to inflate rate for their subsequent operations

        totalSupply += mintTokens;
        balanceOf[msg.sender] += mintTokens;

        underlying.transferFrom(msg.sender, address(this), mintAmount);

        emit Mint(msg.sender, mintAmount, mintTokens);
        return mintTokens;
    }

    /**
     * @dev Redeem cTokens for underlying based on current exchange rate
     */
    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(balanceOf[msg.sender] >= redeemTokens, "Insufficient balance");

        uint256 exchangeRateMantissa = exchangeRate();

        // Calculate underlying: redeemTokens * exchangeRate / 1e18
        // VULNERABILITY 6: Manipulated rate allows redeeming far more than deposited
        uint256 redeemAmount = (redeemTokens * exchangeRateMantissa) / 1e18;

        balanceOf[msg.sender] -= redeemTokens;
        totalSupply -= redeemTokens;

        // VULNERABILITY 7: Contract pays out based on manipulated calculation
        underlying.transfer(msg.sender, redeemAmount);

        emit Redeem(msg.sender, redeemAmount, redeemTokens);
        return redeemAmount;
    }

    /**
     * @dev Get account's current underlying balance (for collateral calculation)
     */
    function balanceOfUnderlying(
        address account
    ) external view returns (uint256) {
        uint256 exchangeRateMantissa = exchangeRate();

        // VULNERABILITY 8: Inflated exchange rate makes collateral appear much larger
        // This allows borrowing more from other markets than justified
        return (balanceOf[account] * exchangeRateMantissa) / 1e18;
    }
}

/**
 * ATTACK SCENARIO:
 *
 * Setup Phase:
 * 1. Sonne Finance deploys new soWETH market (low initial liquidity)
 * 2. Initial market state:
 *    - totalSupply: 0
 *    - totalUnderlying: 0
 *
 * Manipulation Phase:
 * 1. Attacker mints minimal amount:
 *    mint(1 wei WETH)
 *    - Receives 1 soWETH token
 *    - totalSupply: 1
 *    - totalUnderlying: 1
 *
 * 2. Attacker directly transfers large amount to contract:
 *    WETH.transfer(soWETH_contract, 200 WETH)
 *    - This is a donation, not a mint
 *    - totalSupply: still 1
 *    - totalUnderlying: now 200 * 1e18 + 1
 *
 * 3. Exchange rate now massively inflated:
 *    exchangeRate = (200e18 + 1) / 1 = 200e18
 *    - Should be 1e18
 *    - Now 200 billion times higher!
 *
 * Exploitation Phase:
 * 1. Attacker deposits small amount normally:
 *    mint(1 WETH)
 *    - Gets: 1e18 / 200e18 = ~0 soWETH (rounds to tiny amount)
 *
 * 2. Better approach - attacker uses inflated collateral value:
 *    - Their 1 soWETH token appears worth 200 WETH
 *    - Comptroller values collateral at inflated exchangeRate
 *    - Can borrow up to collateral factor * 200 WETH from other markets
 *
 * 3. Attacker borrows maximum from all markets:
 *    - USDC market: borrow $7M
 *    - DAI market: borrow $5M
 *    - WETH market: borrow $8M
 *    - Total: ~$20M borrowed against ~$1 actual collateral
 *
 * 4. Attacker transfers borrowed assets to external wallet
 * 5. Abandons manipulated position
 *
 * MITIGATION STRATEGIES:
 *
 * 1. Minimum Liquidity Lock:
 *    if (totalSupply == 0) {
 *        // Burn first 1000 tokens permanently
 *        totalSupply = 1000;
 *        balanceOf[address(0)] = 1000;
 *    }
 *
 * 2. Virtual Reserves (Uniswap V2 style):
 *    uint256 totalUnderlying = cash + totalBorrows - totalReserves + VIRTUAL_RESERVE;
 *    uint256 supply = totalSupply + VIRTUAL_SUPPLY;
 *    return (totalUnderlying * 1e18) / supply;
 *
 * 3. Exchange Rate Sanity Checks:
 *    uint256 newRate = calculateRate();
 *    require(newRate <= lastRate * 110 / 100, "Rate increased too fast");
 *    require(newRate >= lastRate * 90 / 100, "Rate decreased too fast");
 *
 * 4. Minimum Market Liquidity:
 *    require(totalSupply >= MIN_LIQUIDITY, "Market too small");
 *
 * 5. Time-Weighted Average Exchange Rate:
 *    - Use TWAP for collateral valuation
 *    - Harder to manipulate in single transaction
 *
 * 6. Deposit/Withdrawal Caps:
 *    - Limit size of first deposits
 *    - Gradual liquidity bootstrapping
 *
 * 7. Circuit Breakers:
 *    - Pause market if exchange rate jumps > X%
 *    - Require admin review for unusual movements
 */
