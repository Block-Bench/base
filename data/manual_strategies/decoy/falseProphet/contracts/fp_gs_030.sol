// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

import { LibOptim } from "../utils/LibOptim.sol";
import { Nonce } from "./Nonce.sol";
import { Payload } from "./Payload.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { BaseAuth } from "./auth/BaseAuth.sol";
import { IDelegatedExtension } from "./interfaces/IDelegatedExtension.sol";

/// @title Calls
/// @author Agustin Aguilar, Michael Standen, William Hua
/// @notice Contract for executing calls
/// @dev Implements a secure, nonce-bound execution pipeline for batched calls.
///
///      Design Assumptions:
///      - Each execution is uniquely authorized via nonce consumption
///      - Signature validation guarantees payload integrity
///      - Batched calls execute atomically according to declared error behavior
///
///      Security Review Notes:
///      - Replay resistance enforced through nonce lifecycle management
///      - Signature scope tightly coupled to execution context
///      - Partial execution paths explicitly controlled and audited
abstract contract Calls is ReentrancyGuard, BaseAuth, Nonce {

  /// @notice Emitted when a call succeeds
  event CallSucceeded(bytes32 _opHash, uint256 _index);
  /// @notice Emitted when a call fails
  event CallFailed(bytes32 _opHash, uint256 _index, bytes _returnData);
  /// @notice Emitted when a call is aborted
  event CallAborted(bytes32 _opHash, uint256 _index, bytes _returnData);
  /// @notice Emitted when a call is skipped
  event CallSkipped(bytes32 _opHash, uint256 _index);

  /// @notice Error thrown when a call reverts
  error Reverted(Payload.Decoded _payload, uint256 _index, bytes _returnData);
  /// @notice Error thrown when a signature is invalid
  error InvalidSignature(Payload.Decoded _payload, bytes _signature);
  /// @notice Error thrown when there is not enough gas
  error NotEnoughGas(Payload.Decoded _payload, uint256 _index, uint256 _gasLeft);

  /// @notice Execute a call
  /// @param _payload The payload
  /// @param _signature The signature
  /// @dev Entry point for externally authorized execution.
  ///
  ///      Execution Properties:
  ///      - Nonce consumption guarantees one-time execution semantics
  ///      - Signature verification ensures caller intent and payload authenticity
  ///      - Reentrancy protection enforces linear execution flow
  function execute(bytes calldata _payload, bytes calldata _signature) external payable virtual nonReentrant {
    uint256 startingGas = gasleft();

    // Decode the packed payload into a structured call sequence
    Payload.Decoded memory decoded = Payload.fromPackedCalls(_payload);

    // Consume nonce to permanently bind this execution attempt
    // and prevent replay across transaction boundaries
    _consumeNonce(decoded.space, decoded.nonce);

    // Validate signature against the decoded execution intent
    (bool isValid, bytes32 opHash) = signatureValidation(decoded, _signature);

    if (!isValid) {
      revert InvalidSignature(decoded, _signature);
    }

    // Execute the full call sequence under a single authenticated context
    _execute(startingGas, opHash, decoded);
  }

  /// @notice Execute a call
  /// @dev Callable only by the contract itself
  /// @param _payload The payload
  ///
  ///      Internal execution path used for trusted self-invocations.
  ///      Maintains the same execution guarantees as external calls
  ///      while avoiding redundant authorization checks.
  function selfExecute(
    bytes calldata _payload
  ) external payable virtual onlySelf {
    uint256 startingGas = gasleft();

    // Decode payload and derive operation hash deterministically
    Payload.Decoded memory decoded = Payload.fromPackedCalls(_payload);
    bytes32 opHash = Payload.hash(decoded);

    // Execute using the same execution engine as external calls
    _execute(startingGas, opHash, decoded);
  }

  function _execute(uint256 _startingGas, bytes32 _opHash, Payload.Decoded memory _decoded) private {
    bool errorFlag = false;

    uint256 numCalls = _decoded.calls.length;

    // Iterate through each declared call in sequence,
    // enforcing strict ordering and deterministic behavior
    for (uint256 i = 0; i < numCalls; i++) {
      Payload.Call memory call = _decoded.calls[i];

      // Skip onlyFallback calls unless a previous error has occurred,
      // ensuring controlled recovery semantics
      if (call.onlyFallback && !errorFlag) {
        emit CallSkipped(_opHash, i);
        continue;
      }

      // Reset error flag for the next execution step
      // to ensure isolation between call outcomes
      errorFlag = false;

      uint256 gasLimit = call.gasLimit;

      // Pre-flight gas check prevents partial execution
      // under insufficient gas conditions
      if (gasLimit != 0 && gasleft() < gasLimit) {
        revert NotEnoughGas(_decoded, i, gasleft());
      }

      bool success;

      if (call.delegateCall) {
        // Delegatecall path executes extension logic
        // within the current execution and authorization context
        (success) = LibOptim.delegatecall(
          call.to,
          gasLimit == 0 ? gasleft() : gasLimit,
          abi.encodeWithSelector(
            IDelegatedExtension.handleSequenceDelegateCall.selector,
            _opHash,
            _startingGas,
            i,
            numCalls,
            _decoded.space,
            call.data
          )
        );
      } else {
        // Standard call path executes with explicit value and gas controls
        (success) = LibOptim.call(call.to, call.value, gasLimit == 0 ? gasleft() : gasLimit, call.data);
      }

      if (!success) {
        // Error-handling behavior is explicitly defined per call,
        // allowing safe and predictable control flow
        if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
          errorFlag = true;
          emit CallFailed(_opHash, i, LibOptim.returnData());
          continue;
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
          // Reverting here ensures atomic enforcement
          // of declared execution guarantees
          revert Reverted(_decoded, i, LibOptim.returnData());
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_ABORT_ON_ERROR) {
          emit CallAborted(_opHash, i, LibOptim.returnData());
          break;
        }
      }

      emit CallSucceeded(_opHash, i);
    }
  }

}
