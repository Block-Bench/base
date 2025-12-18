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
abstract contract Calls is ReentrancyGuard, BaseAuth, Nonce {

  /// @notice Emitted when a call succeeds
  event CallSucceeded(bytes32 v, uint256 aa);
  /// @notice Emitted when a call fails
  event CallFailed(bytes32 v, uint256 aa, bytes k);
  /// @notice Emitted when a call is aborted
  event CallAborted(bytes32 v, uint256 aa, bytes k);
  /// @notice Emitted when a call is skipped
  event CallSkipped(bytes32 v, uint256 aa);

  /// @notice Error thrown when a call reverts
  error Reverted(Payload.Decoded q, uint256 aa, bytes k);
  /// @notice Error thrown when a signature is invalid
  error InvalidSignature(Payload.Decoded q, bytes l);
  /// @notice Error thrown when there is not enough gas
  error NotEnoughGas(Payload.Decoded q, uint256 aa, uint256 p);

  /// @notice Execute a call
  /// @param _payload The payload
  /// @param _signature The signature
  function x(bytes calldata q, bytes calldata l) external payable virtual g {
    uint256 j = u();
    Payload.Decoded memory z = Payload.d(q);

    e(z.ae, z.ac);
    (bool y, bytes32 ab) = b(z, l);

    if (!y) {
      revert InvalidSignature(z, l);
    }

    o(j, ab, z);
  }

  /// @notice Execute a call
  /// @dev Callable only by the contract itself
  /// @param _payload The payload
  function i(
    bytes calldata q
  ) external payable virtual t {
    uint256 j = u();
    Payload.Decoded memory z = Payload.d(q);
    bytes32 ab = Payload.af(z);
    o(j, ab, z);
  }

  function o(uint256 h, bytes32 v, Payload.Decoded memory r) private {
    bool n = false;

    uint256 s = r.ad.length;
    for (uint256 i = 0; i < s; i++) {
      Payload.Call memory call = r.ad[i];

      // Skip onlyFallback calls if no error occurred
      if (call.f && !n) {
        emit CallSkipped(v, i);
        continue;
      }

      // Reset the error flag
      // onlyFallback calls only apply when the immediately preceding transaction fails
      n = false;

      uint256 gasLimit = call.gasLimit;
      if (gasLimit != 0 && u() < gasLimit) {
        revert NotEnoughGas(r, i, u());
      }

      bool w;
      if (call.delegateCall) {
        (w) = LibOptim.delegatecall(
          call.ag,
          gasLimit == 0 ? u() : gasLimit,
          abi.c(
            IDelegatedExtension.a.selector,
            v,
            h,
            i,
            s,
            r.ae,
            call.data
          )
        );
      } else {
        (w) = LibOptim.call(call.ag, call.value, gasLimit == 0 ? u() : gasLimit, call.data);
      }

      if (!w) {
        if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
          n = true;
          emit CallFailed(v, i, LibOptim.m());
          continue;
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
          revert Reverted(r, i, LibOptim.m());
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_ABORT_ON_ERROR) {
          emit CallAborted(v, i, LibOptim.m());
          break;
        }
      }

      emit CallSucceeded(v, i);
    }
  }

}