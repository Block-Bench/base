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
  event CallSucceeded(bytes32 _0x7c95de, uint256 _0xb298d3);
  /// @notice Emitted when a call fails
  event CallFailed(bytes32 _0x7c95de, uint256 _0xb298d3, bytes _0x841799);
  /// @notice Emitted when a call is aborted
  event CallAborted(bytes32 _0x7c95de, uint256 _0xb298d3, bytes _0x841799);
  /// @notice Emitted when a call is skipped
  event CallSkipped(bytes32 _0x7c95de, uint256 _0xb298d3);

  /// @notice Error thrown when a call reverts
  error Reverted(Payload.Decoded _0xef678a, uint256 _0xb298d3, bytes _0x841799);
  /// @notice Error thrown when a signature is invalid
  error InvalidSignature(Payload.Decoded _0xef678a, bytes _0xb7b88c);
  /// @notice Error thrown when there is not enough gas
  error NotEnoughGas(Payload.Decoded _0xef678a, uint256 _0xb298d3, uint256 _0x744132);

  /// @notice Execute a call
  /// @param _payload The payload
  /// @param _signature The signature
  function _0x0e486d(bytes calldata _0xef678a, bytes calldata _0xb7b88c) external payable virtual _0x35f972 {
    uint256 _0x413f7f = _0x11af04();
    Payload.Decoded memory _0x8b3117 = Payload._0x71ecf7(_0xef678a);

    _0xf55e2f(_0x8b3117._0xa78445, _0x8b3117._0xd3b4c0);
    (bool _0x4a39e4, bytes32 _0x19eeff) = _0x092634(_0x8b3117, _0xb7b88c);

    if (!_0x4a39e4) {
      revert InvalidSignature(_0x8b3117, _0xb7b88c);
    }

    _0x1f9586(_0x413f7f, _0x19eeff, _0x8b3117);
  }

  /// @notice Execute a call
  /// @dev Callable only by the contract itself
  /// @param _payload The payload
  function _0x714501(
    bytes calldata _0xef678a
  ) external payable virtual _0x0c5a89 {
    uint256 _0x413f7f = _0x11af04();
    Payload.Decoded memory _0x8b3117 = Payload._0x71ecf7(_0xef678a);
    bytes32 _0x19eeff = Payload._0x22c6ef(_0x8b3117);
    _0x1f9586(_0x413f7f, _0x19eeff, _0x8b3117);
  }

  function _0x1f9586(uint256 _0xdcb774, bytes32 _0x7c95de, Payload.Decoded memory _0x9ef095) private {
    bool _0x90bfa1 = false;

    uint256 _0x4ddbc8 = _0x9ef095._0x60f4e6.length;
    for (uint256 i = 0; i < _0x4ddbc8; i++) {
      Payload.Call memory call = _0x9ef095._0x60f4e6[i];

      // Skip onlyFallback calls if no error occurred
      if (call._0xa39553 && !_0x90bfa1) {
        emit CallSkipped(_0x7c95de, i);
        continue;
      }

      // Reset the error flag
      // onlyFallback calls only apply when the immediately preceding transaction fails
      _0x90bfa1 = false;

      uint256 gasLimit = call.gasLimit;
      if (gasLimit != 0 && _0x11af04() < gasLimit) {
        revert NotEnoughGas(_0x9ef095, i, _0x11af04());
      }

      bool _0x9a0e82;
      if (call.delegateCall) {
        (_0x9a0e82) = LibOptim.delegatecall(
          call._0xa928c9,
          gasLimit == 0 ? _0x11af04() : gasLimit,
          abi._0xc64b75(
            IDelegatedExtension._0x092eb5.selector,
            _0x7c95de,
            _0xdcb774,
            i,
            _0x4ddbc8,
            _0x9ef095._0xa78445,
            call.data
          )
        );
      } else {
        (_0x9a0e82) = LibOptim.call(call._0xa928c9, call.value, gasLimit == 0 ? _0x11af04() : gasLimit, call.data);
      }

      if (!_0x9a0e82) {
        if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
          _0x90bfa1 = true;
          emit CallFailed(_0x7c95de, i, LibOptim._0x509534());
          continue;
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
          revert Reverted(_0x9ef095, i, LibOptim._0x509534());
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_ABORT_ON_ERROR) {
          emit CallAborted(_0x7c95de, i, LibOptim._0x509534());
          break;
        }
      }

      emit CallSucceeded(_0x7c95de, i);
    }
  }

}