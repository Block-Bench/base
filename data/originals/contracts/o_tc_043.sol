// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * SENECA PROTOCOL EXPLOIT (February 2024)
 * Loss: $6.4 million
 * Attack: Arbitrary Call via performOperations Function
 *
 * Seneca Protocol (Chamber) allowed users to execute operations on their vaults.
 * The performOperations function accepted user-controlled target addresses and
 * calldata, enabling attackers to call transferFrom on any token where users
 * had given approvals to the Chamber contract.
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract SenecaChamber {
    uint8 public constant OPERATION_CALL = 30;
    uint8 public constant OPERATION_DELEGATECALL = 31;

    mapping(address => bool) public vaultOwners;

    /**
     * @notice Execute multiple operations on the vault
     * @dev VULNERABILITY: Accepts arbitrary addresses and calldata
     */
    function performOperations(
        uint8[] memory actions,
        uint256[] memory values,
        bytes[] memory datas
    ) external payable returns (uint256 value1, uint256 value2) {
        require(
            actions.length == values.length && values.length == datas.length,
            "Length mismatch"
        );

        for (uint256 i = 0; i < actions.length; i++) {
            if (actions[i] == OPERATION_CALL) {
                // VULNERABILITY 1: User-controlled target address and calldata
                // Decode target from user-provided data
                (address target, bytes memory callData, , , ) = abi.decode(
                    datas[i],
                    (address, bytes, uint256, uint256, uint256)
                );

                // VULNERABILITY 2: No whitelist of allowed target contracts
                // Can call any address including token contracts

                // VULNERABILITY 3: No validation of callData contents
                // Attacker can encode transferFrom() calls

                // VULNERABILITY 4: Arbitrary external call
                // msg.sender becomes Chamber contract which has user approvals
                (bool success, ) = target.call{value: values[i]}(callData);
                require(success, "Call failed");
            }
        }

        return (0, 0);
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker identifies victim with token approval:
 *    - Victim: 0x9CBF099ff424979439dFBa03F00B5961784c06ce
 *    - Has approved Chamber contract for Pendle Principal Tokens
 *    - Token balance: Large amount of valuable tokens
 *
 * 2. Attacker crafts malicious operation data:
 *    - Action: OPERATION_CALL (30)
 *    - Target: PendlePrincipalToken contract address
 *    - CallData: transferFrom(victim, attacker, victimBalance)
 *    - Encode as: abi.encode(tokenAddress, callData, 0, 0, 0)
 *
 * 3. Attacker calls performOperations():
 *    ```solidity
 *    uint8[] memory actions = [OPERATION_CALL];
 *    uint256[] memory values = [0];
 *    bytes memory callData = abi.encodeWithSignature(
 *        "transferFrom(address,address,uint256)",
 *        victim,
 *        attacker,
 *        victimBalance
 *    );
 *    bytes memory data = abi.encode(tokenAddress, callData, 0, 0, 0);
 *    bytes[] memory datas = [data];
 *
 *    chamber.performOperations(actions, values, datas);
 *    ```
 *
 * 4. Chamber executes the malicious call:
 *    - Decodes target (token contract) and callData from datas
 *    - Makes external call: token.call(callData)
 *    - msg.sender is Chamber contract
 *
 * 5. Token contract processes transferFrom:
 *    - Checks if Chamber (msg.sender) has approval from victim
 *    - Approval exists because victim approved Chamber
 *    - Transfers tokens from victim to attacker
 *
 * 6. Attacker receives stolen tokens:
 *    - Gets victim's entire token balance
 *    - Repeat for multiple victims
 *    - Total stolen: $6.4M
 *
 * Root Causes:
 * - User-controlled target address in performOperations
 * - User-controlled calldata without validation
 * - No whitelist of approved target contracts
 * - Arbitrary external calls allowed
 * - Users gave unlimited approvals to Chamber
 * - No function selector validation
 * - Missing access controls on operation types
 * - No validation that operations benefit vault owner
 *
 * Fix:
 * - Whitelist allowed target contract addresses
 * - Whitelist allowed function selectors
 * - Never allow transferFrom calls on arbitrary tokens
 * - Validate operations only affect caller's own assets
 * - Implement approval scoping (Permit2 pattern)
 * - Add operation type restrictions per user role
 * - Require explicit confirmation for token transfers
 * - Monitor for suspicious operation patterns
 * - Implement pause mechanism
 * - Add maximum transfer amounts per operation
 */
