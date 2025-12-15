// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * QUBIT BRIDGE EXPLOIT (January 2022)
 *
 * Attack Vector: Zero Address Validation Bypass
 * Loss: $80 million
 *
 * VULNERABILITY:
 * The Qubit Bridge allowed users to deposit tokens on Ethereum and mint
 * corresponding tokens on BSC. The vulnerability was in the deposit handler
 * which failed to validate that the deposited token address was not zero.
 *
 * By passing address(0) as the token contract, the attacker could bypass
 * the actual token transfer but still trigger minting on the destination chain.
 *
 * Attack Steps:
 * 1. Call deposit() with resourceID mapped to address(0)
 * 2. No tokens are actually transferred (address(0) has no code)
 * 3. Bridge emits deposit event anyway
 * 4. BSC handler sees event and mints tokens
 * 5. Attacker receives minted tokens without depositing real collateral
 * 6. Repeated calls to drain $80M from bridge reserves
 */

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract QBridge {
    address public handler;

    event Deposit(
        uint8 destinationDomainID,
        bytes32 resourceID,
        uint64 depositNonce
    );

    uint64 public depositNonce;

    constructor(address _handler) {
        handler = _handler;
    }

    /**
     * @notice Initiates a bridge deposit
     * @dev VULNERABLE: Does not validate resourceID or token address
     */
    function deposit(
        uint8 destinationDomainID,
        bytes32 resourceID,
        bytes calldata data
    ) external payable {
        depositNonce += 1;

        // Forward to handler - this is where the vulnerability occurs
        QBridgeHandler(handler).deposit(resourceID, msg.sender, data);

        emit Deposit(destinationDomainID, resourceID, depositNonce);
    }
}

contract QBridgeHandler {
    mapping(bytes32 => address) public resourceIDToTokenContractAddress;
    mapping(address => bool) public contractWhitelist;

    /**
     * @notice Process bridge deposit
     * @dev VULNERABLE: Does not validate that tokenContract is not address(0)
     */
    function deposit(
        bytes32 resourceID,
        address depositer,
        bytes calldata data
    ) external {
        address tokenContract = resourceIDToTokenContractAddress[resourceID];

        // VULNERABILITY: If tokenContract is address(0), this passes silently
        // contractWhitelist[address(0)] may be false, but the check might be skipped
        // or address(0) might accidentally be whitelisted

        uint256 amount;
        (amount) = abi.decode(data, (uint256));

        // CRITICAL VULNERABILITY: If tokenContract == address(0),
        // this call will not revert (calling address(0) returns success)
        // No tokens are actually transferred!
        IERC20(tokenContract).transferFrom(depositer, address(this), amount);

        // But the deposit event was already emitted in the bridge contract
        // The destination chain handler sees this event and mints tokens
        // Attacker gets minted tokens without providing real collateral
    }

    /**
     * @notice Set resource ID to token mapping
     */
    function setResource(bytes32 resourceID, address tokenAddress) external {
        resourceIDToTokenContractAddress[resourceID] = tokenAddress;

        // VULNERABILITY: If tokenAddress is set to address(0), either accidentally
        // or through an attack, deposits with this resourceID will fail silently
        // but still emit events that trigger minting on destination chain
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * Setup:
 * - Attacker finds or creates a resourceID that maps to address(0)
 * - This could happen if resourceID was never properly initialized
 * - Or if there's a way to manipulate the mapping
 *
 * Attack:
 * 1. Craft deposit() call with:
 *    - destinationDomainID: 1 (BSC)
 *    - resourceID: 0x0000...01 (maps to address(0))
 *    - data: encoded amount (e.g., 77,162 ETH worth)
 *
 * 2. Bridge calls handler.deposit(resourceID, attacker, data)
 *
 * 3. Handler retrieves tokenContract = address(0)
 *
 * 4. Handler calls IERC20(address(0)).transferFrom(...)
 *    - This does NOT revert (calling address(0) returns success in EVM)
 *    - No actual tokens are transferred
 *
 * 5. Bridge emits Deposit event
 *
 * 6. BSC side handler sees the event
 *
 * 7. BSC handler mints tokens to attacker's address
 *
 * 8. Attacker repeats multiple times to drain $80M
 *
 * Root Cause:
 * - Missing validation that tokenContract != address(0)
 * - Missing validation that resourceID is properly initialized
 * - Trusting that transferFrom to address(0) would revert
 *
 * Fix:
 * require(tokenContract != address(0), "Invalid token");
 * require(contractWhitelist[tokenContract], "Not whitelisted");
 */
