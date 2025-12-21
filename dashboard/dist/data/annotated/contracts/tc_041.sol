// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * SHEZMU EXPLOIT (September 2024)
 * Loss: $4.9 million
 * Attack: Missing Access Control on Mint Function
 *
 * Shezmu is a CDP (Collateralized Debt Position) protocol. The collateral
 * token contract had a publicly accessible mint() function with no access
 * control, allowing anyone to mint unlimited collateral tokens and borrow
 * against them to drain the vault.
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

contract ShezmuCollateralToken is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    /**
     * @notice Mint new collateral tokens
     * @dev VULNERABILITY: No access control - anyone can call this
     */
    function mint(address to, uint256 amount) external {
        // VULNERABILITY 1: Missing access control modifier
        // Should have: require(msg.sender == owner, "Only owner");
        // or: require(hasRole(MINTER_ROLE, msg.sender), "Not authorized");

        // VULNERABILITY 2: No minting limits
        // Can mint type(uint128).max worth of tokens

        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public collateralToken;
    IERC20 public shezUSD;

    mapping(address => uint256) public collateralBalance;
    mapping(address => uint256) public debtBalance;

    uint256 public constant COLLATERAL_RATIO = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        collateralToken = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    /**
     * @notice Add collateral to vault
     */
    function addCollateral(uint256 amount) external {
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateralBalance[msg.sender] += amount;
    }

    /**
     * @notice Borrow ShezUSD against collateral
     * @dev VULNERABLE: Allows borrowing if collateral exists, even if minted without authorization
     */
    function borrow(uint256 amount) external {
        // VULNERABILITY 3: Accepts any collateral, including illegitimately minted tokens
        // No way to validate if collateral was minted through proper channels

        uint256 maxBorrow = (collateralBalance[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            debtBalance[msg.sender] + amount <= maxBorrow,
            "Insufficient collateral"
        );

        debtBalance[msg.sender] += amount;

        // VULNERABILITY 4: Drains real ShezUSD from vault
        // Attacker gets real value using fake collateral
        shezUSD.transfer(msg.sender, amount);
    }

    function repay(uint256 amount) external {
        require(debtBalance[msg.sender] >= amount, "Excessive repayment");
        shezUSD.transferFrom(msg.sender, address(this), amount);
        debtBalance[msg.sender] -= amount;
    }

    function withdrawCollateral(uint256 amount) external {
        require(
            collateralBalance[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingCollateral = collateralBalance[msg.sender] - amount;
        uint256 maxDebt = (remainingCollateral * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            debtBalance[msg.sender] <= maxDebt,
            "Would be undercollateralized"
        );

        collateralBalance[msg.sender] -= amount;
        collateralToken.transfer(msg.sender, amount);
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker discovers mint() function has no access control:
 *    - Anyone can call ShezmuCollateralToken.mint()
 *    - No owner check, no role requirement
 *    - Can mint unlimited amounts
 *
 * 2. Attacker mints maximum collateral tokens:
 *    - Calls mint(attackerAddress, type(uint128).max - 1)
 *    - Receives ~1.7e38 collateral tokens
 *    - Cost: Only gas fees
 *
 * 3. Approve vault to use collateral:
 *    - Approve ShezmuVault to spend collateral tokens
 *
 * 4. Deposit minted collateral into vault:
 *    - Call addCollateral(type(uint128).max - 1)
 *    - Vault accepts the illegitimately minted collateral
 *    - No validation of token origin
 *
 * 5. Borrow maximum ShezUSD:
 *    - Calculate max borrow based on collateral ratio (150%)
 *    - Borrow ~$4.9M worth of ShezUSD
 *    - Vault transfers real ShezUSD tokens
 *
 * 6. Extract profits:
 *    - Transfer borrowed ShezUSD to attacker wallet
 *    - Abandon collateral position (worthless fake tokens)
 *    - Convert ShezUSD to other assets
 *
 * Root Causes:
 * - Missing access control on mint() function
 * - No owner/admin role check
 * - No minting permissions system
 * - Vault accepts any token as collateral without validation
 * - No way to distinguish legitimately minted vs fake collateral
 * - Missing pause functionality
 *
 * Fix:
 * - Add access control to mint():
 *   ```solidity
 *   modifier onlyOwner() {
 *       require(msg.sender == owner, "Not authorized");
 *       _;
 *   }
 *   function mint(address to, uint256 amount) external onlyOwner {
 *   ```
 * - Implement role-based access control (OpenZeppelin AccessControl)
 * - Add minting limits and rate limiting
 * - Implement supply caps
 * - Add circuit breakers for unusual minting activity
 * - Require multi-sig for minting operations
 * - Monitor for large mints and pause if detected
 */
