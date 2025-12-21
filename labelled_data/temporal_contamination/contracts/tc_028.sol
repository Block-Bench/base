// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * BVAULTS (SAFEMOON) EXPLOIT (May 2021)
 * Attack: Liquidity Pool Drain via Token Manipulation
 * Loss: $8.5 million
 * 
 * SafeMoon-style tokens with transfer fees/burns can be exploited
 * when pools don't account for the actual received amounts.
 */

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract DeflatToken {
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;
    uint256 public feePercent = 10; // 10% burn on transfer
    
    function transfer(address to, uint256 amount) external returns (bool) {
        uint256 fee = (amount * feePercent) / 100;
        uint256 amountAfterFee = amount - fee;
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amountAfterFee;
        totalSupply -= fee; // Burn fee
        
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 fee = (amount * feePercent) / 100;
        uint256 amountAfterFee = amount - fee;
        
        balanceOf[from] -= amount;
        balanceOf[to] += amountAfterFee;
        totalSupply -= fee;
        
        return true;
    }
}

contract VulnerableVault {
    address public token;
    mapping(address => uint256) public deposits;
    
    constructor(address _token) {
        token = _token;
    }
    
    function deposit(uint256 amount) external {
        // VULNERABLE: Assumes full amount is received
        // Doesn't check actual balance increase
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        deposits[msg.sender] += amount; // Records full amount
        // But only received amount - fee!
    }
    
    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");
        
        deposits[msg.sender] -= amount;
        
        // VULNERABILITY: Transfers full amount user deposited
        // But vault actually received less due to transfer fee
        IERC20(token).transfer(msg.sender, amount);
    }
}

/**
 * EXPLOIT:
 * 1. Deflation token charges 10% fee on transfers
 * 2. Attacker deposits 100 tokens
 * 3. Vault receives only 90 tokens (10% burned)
 * 4. Vault credits attacker with 100 tokens in deposits[]
 * 5. Attacker withdraws 100 tokens
 * 6. Vault sends 100 tokens (but had 90 + others' deposits)
 * 7. Repeat to drain $8.5M from vault
 * 
 * Fix: Check actual balance before/after transfer:
 * uint256 balBefore = token.balanceOf(address(this));
 * token.transferFrom(...);
 * uint256 received = token.balanceOf(address(this)) - balBefore;
 * deposits[msg.sender] += received;
 */
