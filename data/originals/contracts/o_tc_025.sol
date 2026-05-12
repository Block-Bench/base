// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * HUNDRED FINANCE EXPLOIT (March 2022)  
 * Attack: ERC667 Token Hooks Reentrancy
 * Loss: $6 million
 * 
 * ERC667 tokens have transfer hooks that call recipient contracts.
 * Hundred Finance (Compound fork) didn't account for reentrancy during
 * the token transfer, allowing attackers to re-enter and manipulate state.
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundToken {
    function borrow(uint256 amount) external;
    function repayBorrow(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function mint(uint256 amount) external;
}

contract HundredFinanceMarket {
    mapping(address => uint256) public accountBorrows;
    mapping(address => uint256) public accountTokens;
    
    address public underlying;
    uint256 public totalBorrows;
    
    constructor(address _underlying) {
        underlying = _underlying;
    }
    
    function borrow(uint256 amount) external {
        accountBorrows[msg.sender] += amount;
        totalBorrows += amount;
        
        // VULNERABLE: Transfer before updating state completely
        // If underlying is ERC667, it can call back during transfer
        IERC20(underlying).transfer(msg.sender, amount);
    }
    
    function repayBorrow(uint256 amount) external {
        // Transfer tokens from user
        IERC20(underlying).transferFrom(msg.sender, address(this), amount);
        
        // Update borrow state
        accountBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}

/**
 * EXPLOIT: 
 * 1. Flash loan ERC667 tokens
 * 2. Call borrow() 
 * 3. During transfer, ERC667 calls back to attacker
 * 4. Attacker re-enters borrow() before first borrow completes
 * 5. Can borrow multiple times with same collateral
 * 6. Drain $6M from protocol
 * 
 * Fix: Use reentrancy guards or checks-effects-interactions pattern
 */
