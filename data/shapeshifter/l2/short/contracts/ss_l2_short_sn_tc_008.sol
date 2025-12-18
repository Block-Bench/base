// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Decentralized lending and borrowing platform
 * @dev Users can deposit collateral and borrow against it
 */

interface IOracle {
    function c(address z) external view returns (uint256);
}

interface ICToken {
    function ac(uint256 q) external;

    function x(uint256 i) external;

    function v(uint256 j) external;

    function o() external view returns (address);
}

contract LendingProtocol {
    // Oracle for getting asset prices
    IOracle public y;

    // Collateral factors
    mapping(address => uint256) public d;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public h;

    // User borrows
    mapping(address => mapping(address => uint256)) public l;

    // Supported markets
    mapping(address => bool) public f;

    event Deposit(address indexed ad, address indexed z, uint256 w);
    event Borrow(address indexed ad, address indexed z, uint256 w);

    constructor(address u) {
        y = IOracle(u);
    }

    /**
     * @notice Mint cTokens by depositing underlying assets
     * @param cToken The cToken to mint
     * @param amount Amount of underlying to deposit
     */
    function ac(address z, uint256 w) external {
        require(f[z], "Market not supported");

        // Mint cTokens to user
        h[msg.sender][z] += w;

        emit Deposit(msg.sender, z, w);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The cToken to borrow
     * @param amount Amount to borrow
     */
    function x(address z, uint256 w) external {
        require(f[z], "Market not supported");

        // Calculate user's borrowing power
        uint256 m = b(msg.sender);

        // Calculate current total borrows value
        uint256 g = a(msg.sender);

        // Get value of new borrow
        uint256 n = (y.c(z) * w) /
            1e18;

        // Check if user has enough collateral
        require(
            g + n <= m,
            "Insufficient collateral"
        );

        // Update borrow balance
        l[msg.sender][z] += w;

        emit Borrow(msg.sender, z, w);
    }

    /**
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD
     */
    function b(address ad) public view returns (uint256) {
        uint256 p = 0;

        address[] memory t = new address[](2);

        for (uint256 i = 0; i < t.length; i++) {
            address z = t[i];
            uint256 balance = h[ad][z];

            if (balance > 0) {
                // Get price from oracle
                uint256 aa = y.c(z);

                // Calculate value
                uint256 value = (balance * aa) / 1e18;

                // Apply collateral factor
                uint256 ab = (value * d[z]) / 1e18;

                p += ab;
            }
        }

        return p;
    }

    /**
     * @notice Calculate user's total borrow value
     * @param user The user address
     * @return Total borrow value in USD
     */
    function a(address ad) public view returns (uint256) {
        uint256 k = 0;

        address[] memory t = new address[](2);

        for (uint256 i = 0; i < t.length; i++) {
            address z = t[i];
            uint256 s = l[ad][z];

            if (s > 0) {
                uint256 aa = y.c(z);
                uint256 value = (s * aa) / 1e18;
                k += value;
            }
        }

        return k;
    }

    /**
     * @notice Add a supported market
     * @param cToken The cToken to add
     * @param collateralFactor The collateral factor
     */
    function r(address z, uint256 e) external {
        f[z] = true;
        d[z] = e;
    }
}
