// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * DODO REINITALIZATION EXPLOIT (March 2021)
 * 
 * Attack Vector: Reinitialization Vulnerability
 * Loss: $3.8 million
 * 
 * VULNERABILITY:
 * DODO's liquidity pool contract had an init() function that could be called
 * multiple times without proper access control. The initialization function
 * set critical parameters including fee recipient addresses and token balances.
 * 
 * An attacker could call init() again after deployment, setting themselves
 * as the fee recipient or manipulating pool parameters to drain funds.
 * 
 * Attack Steps:
 * 1. Identify DODO pool contract without initialization lock
 * 2. Call init() with attacker-controlled parameters
 * 3. Set maintainer/fee recipient to attacker address
 * 4. Execute swaps or claim accumulated fees
 * 5. Drain funds from pool
 */

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract DODOPool {
    
    address public maintainer;
    address public baseToken;
    address public quoteToken;
    
    uint256 public lpFeeRate;
    uint256 public baseBalance;
    uint256 public quoteBalance;
    
    bool public isInitialized;
    
    event Initialized(address maintainer, address base, address quote);
    
    /**
     * @notice VULNERABLE: init() can be called multiple times
     * @dev Missing `require(!isInitialized)` check allows reinitialization
     * 
     * This function sets critical pool parameters including the maintainer
     * address (fee recipient). Without proper protection, attackers can
     * call it again to hijack the pool.
     */
    function init(
        address _maintainer,
        address _baseToken,
        address _quoteToken,
        uint256 _lpFeeRate
    ) external {
        // VULNERABILITY: Missing initialization check!
        // Should have: require(!isInitialized, "Already initialized");
        
        maintainer = _maintainer;
        baseToken = _baseToken;
        quoteToken = _quoteToken;
        lpFeeRate = _lpFeeRate;
        
        // Even though we set isInitialized = true, the damage is done
        // The attacker has already changed the maintainer address
        isInitialized = true;
        
        emit Initialized(_maintainer, _baseToken, _quoteToken);
    }
    
    /**
     * @notice Add liquidity to pool
     */
    function addLiquidity(uint256 baseAmount, uint256 quoteAmount) external {
        require(isInitialized, "Not initialized");
        
        IERC20(baseToken).transferFrom(msg.sender, address(this), baseAmount);
        IERC20(quoteToken).transferFrom(msg.sender, address(this), quoteAmount);
        
        baseBalance += baseAmount;
        quoteBalance += quoteAmount;
    }
    
    /**
     * @notice Swap tokens
     */
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external returns (uint256 toAmount) {
        require(isInitialized, "Not initialized");
        require(
            (fromToken == baseToken && toToken == quoteToken) ||
            (fromToken == quoteToken && toToken == baseToken),
            "Invalid token pair"
        );
        
        // Transfer tokens in
        IERC20(fromToken).transferFrom(msg.sender, address(this), fromAmount);
        
        // Calculate swap amount (simplified constant product)
        if (fromToken == baseToken) {
            toAmount = (quoteBalance * fromAmount) / (baseBalance + fromAmount);
            baseBalance += fromAmount;
            quoteBalance -= toAmount;
        } else {
            toAmount = (baseBalance * fromAmount) / (quoteBalance + fromAmount);
            quoteBalance += fromAmount;
            baseBalance -= toAmount;
        }
        
        // Deduct fee for maintainer
        uint256 fee = (toAmount * lpFeeRate) / 10000;
        toAmount -= fee;
        
        // Transfer tokens out
        IERC20(toToken).transfer(msg.sender, toAmount);
        
        // VULNERABILITY: Fees accumulate for maintainer
        // If attacker reinitialized and set themselves as maintainer,
        // they can claim all fees
        IERC20(toToken).transfer(maintainer, fee);
        
        return toAmount;
    }
    
    /**
     * @notice Claim accumulated fees (simplified)
     */
    function claimFees() external {
        require(msg.sender == maintainer, "Only maintainer");
        
        // In the real DODO contract, there was accumulated fee tracking
        // Attacker could reinitialize, set themselves as maintainer,
        // then claim all accumulated fees
        uint256 baseTokenBalance = IERC20(baseToken).balanceOf(address(this));
        uint256 quoteTokenBalance = IERC20(quoteToken).balanceOf(address(this));
        
        // Transfer excess (fees) to maintainer
        if (baseTokenBalance > baseBalance) {
            uint256 excess = baseTokenBalance - baseBalance;
            IERC20(baseToken).transfer(maintainer, excess);
        }
        
        if (quoteTokenBalance > quoteBalance) {
            uint256 excess = quoteTokenBalance - quoteBalance;
            IERC20(quoteToken).transfer(maintainer, excess);
        }
    }
}

/**
 * EXPLOIT SCENARIO:
 * 
 * Initial State:
 * - DODO pool deployed and initialized by legitimate owner
 * - maintainer = 0xLegitOwner
 * - Pool has accumulated $3.8M in fees and liquidity
 * 
 * Attack:
 * 1. Attacker notices init() has no initialization guard
 * 
 * 2. Attacker calls:
 *    init(
 *      _maintainer: 0xAttacker,  // Hijack maintainer role
 *      _baseToken: <existing>,
 *      _quoteToken: <existing>,
 *      _lpFeeRate: 10000  // Max fees to attacker
 *    )
 * 
 * 3. Now maintainer = 0xAttacker
 * 
 * 4. Attacker can:
 *    a) Call claimFees() to steal accumulated fees
 *    b) All future swap fees go to attacker
 *    c) In some versions, could manipulate baseBalance/quoteBalance
 *       to enable profitable swaps
 * 
 * 5. Drain $3.8M from the pool
 * 
 * Root Cause:
 * - init() function lacked proper initialization guard
 * - Missing: require(!isInitialized, "Already initialized")
 * - Or better: use OpenZeppelin's Initializable pattern
 * 
 * Fix:
 * ```solidity
 * bool private initialized;
 * 
 * function init(...) external {
 *     require(!initialized, "Already initialized");
 *     initialized = true;
 *     // ... rest of initialization
 * }
 * ```
 * 
 * Or use OpenZeppelin Initializable:
 * ```solidity
 * import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
 * 
 * contract DODOPool is Initializable {
 *     function init(...) external initializer {
 *         // ... initialization logic
 *     }
 * }
 * ```
 */
