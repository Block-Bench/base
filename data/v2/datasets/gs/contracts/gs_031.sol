// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;


// ===== AUTO-GENERATED STUBS FOR STATIC ANALYSIS =====
interface IAccount {}
interface IERC1271_MAGIC_VALUE_HASH {}
interface IEntryPoint {}
abstract contract Calls {}
abstract contract PackedUserOperation {}
abstract contract ReentrancyGuard { uint256 private _status; modifier nonReentrant() { require(_status != 2); _status = 2; _; _status = 1; } }
// ===== END STUBS =====


/**
 * @title Static signatures bound to caller revert under ERC-4337, causing DoS
 * @notice VULNERABLE CONTRACT - Gold Standard Benchmark Item gs_032
 * @dev Source: CODE4RENA - 
 *
 * VULNERABILITY INFORMATION:
 * - Type: dos
 * - Severity: MEDIUM
 * - Finding ID: M-02
 *
 * DESCRIPTION:
 * In ERC-4337, validateUserOp uses external self-call to isValidSignature, changing
 * msg.sender to wallet instead of entrypoint. BaseAuth.signatureValidation enforces
 * caller binding, causing revert for static signatures bound to entrypoint.
 *
 * VULNERABLE FUNCTIONS:
 * - validateUserOp()
 *
 * VULNERABLE LINES:
 * - Lines: 30, 31, 32, 33, 34, 35, 36, 37, 38, 39... (+15 more)
 *
 * ATTACK SCENARIO:
 * Deploy wallet with static signature bound to entrypoint. Attempt validateUserOp 
 *
 * RECOMMENDED FIX:
 * Avoid external self-call; propagate intended caller into validation.
 */


// ^^^ VULNERABLE LINE ^^^

// ^^^ VULNERABLE LINE ^^^
// ^^^ VULNERABLE LINE ^^^
// ^^^ VULNERABLE LINE ^^^
// ^^^ VULNERABLE LINE ^^^

/// @title ERC4337v07
/// @author Agustin Aguilar, Michael Standen
/// @notice ERC4337 v7 support
abstract contract ERC4337v07 is ReentrancyGuard, IAccount, Calls {
// ^^^ VULNERABLE LINE ^^^

  uint256 internal constant SIG_VALIDATION_FAILED = 1;
  // ^^^ VULNERABLE LINE ^^^

  address public immutable entrypoint;
  // ^^^ VULNERABLE LINE ^^^

  error InvalidEntryPoint(address _entrypoint);
  // ^^^ VULNERABLE LINE ^^^
  error ERC4337Disabled();
  // ^^^ VULNERABLE LINE ^^^

  constructor(
  // ^^^ VULNERABLE LINE ^^^
    address _entrypoint
    // ^^^ VULNERABLE LINE ^^^
  ) {
  // ^^^ VULNERABLE LINE ^^^
    entrypoint = _entrypoint;
  }

  /// @inheritdoc IAccount
    // @audit-issue VULNERABLE FUNCTION: validateUserOp
  function validateUserOp(
    PackedUserOperation calldata userOp,
    bytes32 userOpHash,
    uint256 missingAccountFunds
  ) external returns (uint256 validationData) {
    if (entrypoint == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != entrypoint) {
      revert InvalidEntryPoint(msg.sender);
    }

    // userOp.nonce is validated by the entrypoint

    if (missingAccountFunds != 0) {
      IEntryPoint(entrypoint).depositTo{ value: missingAccountFunds }(address(this));
    }

    if (this.isValidSignature(userOpHash, userOp.signature) != IERC1271_MAGIC_VALUE_HASH) {
      return SIG_VALIDATION_FAILED;
    }

    return 0;
  }

  /// @notice Execute a user operation
  /// @param _payload The packed payload
  /// @dev This is the execute function for the EntryPoint to call.
  function executeUserOp(
    bytes calldata _payload
  ) external nonReentrant {
    if (entrypoint == address(0)) {
      revert ERC4337Disabled();
    }

    if (msg.sender != entrypoint) {
      revert InvalidEntryPoint(msg.sender);
    }

    this.selfExecute(_payload);
  }

}