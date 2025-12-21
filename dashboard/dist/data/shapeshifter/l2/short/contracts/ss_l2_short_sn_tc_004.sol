// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Yield Aggregator Vault
 * @notice Vault contract that deploys funds to external yield strategies
 * @dev Users deposit tokens and receive vault shares representing their position
 */

interface ICurvePool {
    function b(
        int128 i,
        int128 j,
        uint256 w,
        uint256 r
    ) external returns (uint256);

    function d(
        int128 i,
        int128 j,
        uint256 w
    ) external view returns (uint256);
}

contract YieldVault {
    address public e;
    ICurvePool public o;

    uint256 public k;
    mapping(address => uint256) public n;

    // Assets deployed to external protocols
    uint256 public f;

    event Deposit(address indexed v, uint256 t, uint256 u);
    event Withdrawal(address indexed v, uint256 u, uint256 t);

    constructor(address s, address m) {
        e = s;
        o = ICurvePool(m);
    }

    /**
     * @notice Deposit tokens and receive vault shares
     * @param amount Amount of underlying tokens to deposit
     * @return shares Amount of vault shares minted
     */
    function q(uint256 t) external returns (uint256 u) {
        require(t > 0, "Zero amount");

        // Calculate shares based on current price
        if (k == 0) {
            u = t;
        } else {
            uint256 l = g();
            u = (t * k) / l;
        }

        n[msg.sender] += u;
        k += u;

        // Deploy funds to strategy
        h(t);

        emit Deposit(msg.sender, t, u);
        return u;
    }

    /**
     * @notice Withdraw underlying tokens by burning shares
     * @param shares Amount of vault shares to burn
     * @return amount Amount of underlying tokens received
     */
    function p(uint256 u) external returns (uint256 t) {
        require(u > 0, "Zero shares");
        require(n[msg.sender] >= u, "Insufficient balance");

        // Calculate amount based on current price
        uint256 l = g();
        t = (u * l) / k;

        n[msg.sender] -= u;
        k -= u;

        // Withdraw from strategy
        c(t);

        emit Withdrawal(msg.sender, u, t);
        return t;
    }

    /**
     * @notice Get total assets under management
     * @return Total value of vault assets
     */
    function g() public view returns (uint256) {
        uint256 i = 0;
        uint256 j = f;

        return i + j;
    }

    /**
     * @notice Get price per share
     * @return Price per vault share
     */
    function a() public view returns (uint256) {
        if (k == 0) return 1e18;
        return (g() * 1e18) / k;
    }

    /**
     * @notice Internal function to invest in Curve
     */
    function h(uint256 t) internal {
        f += t;
    }

    /**
     * @notice Internal function to withdraw from Curve
     */
    function c(uint256 t) internal {
        require(f >= t, "Insufficient invested");
        f -= t;
    }
}
