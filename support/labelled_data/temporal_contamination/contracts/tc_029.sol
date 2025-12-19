// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * BELT FINANCE EXPLOIT (May 2021)
 * Attack: Strategy Vault Price Manipulation  
 * Loss: $6.2 million
 * 
 * Belt Finance vault strategies relied on manipulatable price oracles
 * for calculating share values during deposits/withdrawals.
 */

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address token) external view returns (uint256);
}

contract BeltStrategy {
    address public wantToken;
    address public oracle;
    uint256 public totalShares;
    
    mapping(address => uint256) public shares;
    
    constructor(address _want, address _oracle) {
        wantToken = _want;
        oracle = _oracle;
    }
    
    function deposit(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 pool = IERC20(wantToken).balanceOf(address(this));
        
        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            // VULNERABLE: Price from oracle can be manipulated
            uint256 price = IPriceOracle(oracle).getPrice(wantToken);
            sharesAdded = (amount * totalShares * 1e18) / (pool * price);
        }
        
        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;
        
        IERC20(wantToken).transferFrom(msg.sender, address(this), amount);
        return sharesAdded;
    }
    
    function withdraw(uint256 sharesAmount) external {
        uint256 pool = IERC20(wantToken).balanceOf(address(this));
        
        // VULNERABLE: Uses manipulated price
        uint256 price = IPriceOracle(oracle).getPrice(wantToken);
        uint256 amount = (sharesAmount * pool * price) / (totalShares * 1e18);
        
        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;
        
        IERC20(wantToken).transfer(msg.sender, amount);
    }
}

/**
 * EXPLOIT:
 * 1. Flash loan to manipulate oracle price down
 * 2. Deposit when price is low (get more shares)
 * 3. Manipulate price back up
 * 4. Withdraw with inflated share value  
 * 5. Profit $6.2M from price manipulation
 * 
 * Fix: Use TWAP oracles, manipulation-resistant pricing
 */
