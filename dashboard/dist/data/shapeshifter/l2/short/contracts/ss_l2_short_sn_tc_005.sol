// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Automated Market Maker Pool
 * @notice Liquidity pool for token swaps with concentrated liquidity
 * @dev Allows users to add liquidity and perform token swaps
 */
contract AMMPool {
    // Token balances in the pool
    mapping(uint256 => uint256) public k; // 0 = token0, 1 = token1

    // LP token
    mapping(address => uint256) public i;
    uint256 public d;

    uint256 private v;
    uint256 private constant f = 1;
    uint256 private constant j = 2;

    event LiquidityAdded(
        address indexed n,
        uint256[2] r,
        uint256 q
    );
    event LiquidityRemoved(
        address indexed n,
        uint256 m,
        uint256[2] r
    );

    constructor() {
        v = f;
    }

    /**
     * @notice Add liquidity to the pool
     * @param amounts Array of token amounts to deposit
     * @param min_mint_amount Minimum LP tokens to mint
     * @return Amount of LP tokens minted
     */
    function e(
        uint256[2] memory r,
        uint256 c
    ) external payable returns (uint256) {
        require(r[0] == msg.value, "ETH amount mismatch");

        // Calculate LP tokens to mint
        uint256 p;
        if (d == 0) {
            p = r[0] + r[1];
        } else {
            uint256 h = k[0] + k[1];
            p = ((r[0] + r[1]) * d) / h;
        }

        require(p >= c, "Slippage");

        // Update balances
        k[0] += r[0];
        k[1] += r[1];

        // Mint LP tokens
        i[msg.sender] += p;
        d += p;

        // Handle ETH operations
        if (r[0] > 0) {
            a(r[0]);
        }

        emit LiquidityAdded(msg.sender, r, p);
        return p;
    }

    /**
     * @notice Remove liquidity from the pool
     * @param lpAmount Amount of LP tokens to burn
     * @param min_amounts Minimum amounts to receive
     */
    function b(
        uint256 o,
        uint256[2] memory g
    ) external {
        require(i[msg.sender] >= o, "Insufficient LP");

        // Calculate amounts to return
        uint256 s = (o * k[0]) / d;
        uint256 u = (o * k[1]) / d;

        require(
            s >= g[0] && u >= g[1],
            "Slippage"
        );

        // Burn LP tokens
        i[msg.sender] -= o;
        d -= o;

        // Update balances
        k[0] -= s;
        k[1] -= u;

        // Transfer tokens
        if (s > 0) {
            payable(msg.sender).transfer(s);
        }

        uint256[2] memory r = [s, u];
        emit LiquidityRemoved(msg.sender, o, r);
    }

    /**
     * @notice Internal function for ETH operations
     */
    function a(uint256 x) internal {
        (bool t, ) = msg.sender.call{value: 0}("");
        require(t, "Transfer failed");
    }

    /**
     * @notice Exchange tokens
     * @param i Index of input token
     * @param j Index of output token
     * @param dx Input amount
     * @param min_dy Minimum output amount
     * @return Output amount
     */
    function l(
        int128 i,
        int128 j,
        uint256 aa,
        uint256 w
    ) external payable returns (uint256) {
        uint256 y = uint256(int256(i));
        uint256 z = uint256(int256(j));

        require(y < 2 && z < 2 && y != z, "Invalid indices");

        // Calculate output amount
        uint256 ab = (aa * k[z]) / (k[y] + aa);
        require(ab >= w, "Slippage");

        if (y == 0) {
            require(msg.value == aa, "ETH mismatch");
            k[0] += aa;
        }

        k[y] += aa;
        k[z] -= ab;

        if (z == 0) {
            payable(msg.sender).transfer(ab);
        }

        return ab;
    }

    receive() external payable {}
}
