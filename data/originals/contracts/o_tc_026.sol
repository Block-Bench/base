// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * ANYSWAP EXPLOIT (January 2022)
 * Attack: Permit Signature Bypass
 * Loss: $8 million
 * 
 * Anyswap's anySwapOutUnderlyingWithPermit() function had incomplete
 * validation of permit signatures, allowing arbitrary token transfers.
 */

interface IERC20Permit {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}

contract AnyswapRouter {
    
    function anySwapOutUnderlyingWithPermit(
        address from,
        address token,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external {
        
        // VULNERABLE: Permit validation incomplete or missing
        // Should validate signature matches 'from' address
        // Attacker can pass invalid v,r,s and still succeed
        
        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            // Attempt permit but don't check if it succeeds
            try IERC20Permit(token).permit(from, address(this), amount, deadline, v, r, s) {} catch {}
        }
        
        // VULNERABILITY: Proceeds even if permit failed!
        // Transfers token without proper authorization
        _anySwapOut(from, token, to, amount, toChainID);
    }
    
    function _anySwapOut(address from, address token, address to, uint256 amount, uint256 toChainID) internal {
        // Bridge logic - burns or locks tokens
        // Since permit wasn't validated, attacker can drain tokens
    }
}

/**
 * EXPLOIT:
 * 1. Call anySwapOutUnderlyingWithPermit with victim's token address
 * 2. Pass invalid v,r,s signature (e.g., all zeros)  
 * 3. Permit fails but function continues
 * 4. Tokens transferred/bridged anyway
 * 5. Repeat to drain $8M
 * 
 * Fix: Require valid permit or existing approval, don't proceed on failure
 */
