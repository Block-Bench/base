
/**
 * @title Session signatures replay across wallets due to missing wallet binding
 * @notice VULNERABLE CONTRACT - Gold Standard Benchmark Item gs_031
 * @dev Source: CODE4RENA - 2025-10-sequence
 *
 * VULNERABILITY INFORMATION:
 * - Type: signature_replay
 * - Severity: MEDIUM
 * - Finding ID: M-01
 *
 * DESCRIPTION:
 * SessionSig.hashCallWithReplayProtection omits wallet address in hash, allowing
 * signatures for one wallet to replay on another with same config and nonce.
 * SessionManager.recoverSapientSignature and BaseAuth.signatureValidation do not
 * bind to msg.sender.
 *
 * VULNERABLE FUNCTIONS:
 * - hashCallWithReplayProtection()
 *
 * VULNERABLE LINES:
 * - Lines: 406, 407, 408, 409, 410, 411, 412, 413, 414, 415... (+6 more)
 *
 * ATTACK SCENARIO:
 * Sign payload for Wallet A, replay on Wallet B (same config, nonce). Drains both 
 *
 * RECOMMENDED FIX:
 * Include address(this) in hashCallWithReplayProtection. Update SDK to hash (wallet,
 * chainId, space, nonce, callIdx, call details).
 */

// Full file content not directly retrievable; vulnerable sections: L406-L421 (hashCallWithReplayProtection missing wallet)