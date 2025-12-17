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
  event CallSucceeded(bytes32 _0xfceda8, uint256 _0x1442d0);
  /// @notice Emitted when a call fails
  event CallFailed(bytes32 _0xfceda8, uint256 _0x1442d0, bytes _0x445900);
  /// @notice Emitted when a call is aborted
  event CallAborted(bytes32 _0xfceda8, uint256 _0x1442d0, bytes _0x445900);
  /// @notice Emitted when a call is skipped
  event CallSkipped(bytes32 _0xfceda8, uint256 _0x1442d0);

  /// @notice Error thrown when a call reverts
  error Reverted(Payload.Decoded _0xa19381, uint256 _0x1442d0, bytes _0x445900);
  /// @notice Error thrown when a signature is invalid
  error InvalidSignature(Payload.Decoded _0xa19381, bytes _0xe01a65);
  /// @notice Error thrown when there is not enough gas
  error NotEnoughGas(Payload.Decoded _0xa19381, uint256 _0x1442d0, uint256 _0x71617b);

  /// @notice Execute a call
  /// @param _payload The payload
  /// @param _signature The signature
  function _0x1d96fe(bytes calldata _0xa19381, bytes calldata _0xe01a65) external payable virtual _0xfc2f5d {
    uint256 _0xf4877c = _0x229f60();
    Payload.Decoded memory _0x4d5267 = Payload._0x7e0b9c(_0xa19381);

    _0x742a76(_0x4d5267._0xb00f80, _0x4d5267._0xa3c250);
    (bool _0xc67043, bytes32 _0xe857fc) = _0x45953f(_0x4d5267, _0xe01a65);

    if (!_0xc67043) {
      revert InvalidSignature(_0x4d5267, _0xe01a65);
    }

    _0x1b64db(_0xf4877c, _0xe857fc, _0x4d5267);
  }

  /// @notice Execute a call
  /// @dev Callable only by the contract itself
  /// @param _payload The payload
  function _0xdff47d(
    bytes calldata _0xa19381
  ) external payable virtual _0x8d7fd9 {
    uint256 _0xf4877c = _0x229f60();
    Payload.Decoded memory _0x4d5267 = Payload._0x7e0b9c(_0xa19381);
    bytes32 _0xe857fc = Payload._0x0a4842(_0x4d5267);
    _0x1b64db(_0xf4877c, _0xe857fc, _0x4d5267);
  }

  function _0x1b64db(uint256 _0x347340, bytes32 _0xfceda8, Payload.Decoded memory _0x02dee9) private {
    bool _0x88b61b = false;

    uint256 _0x1a2196 = _0x02dee9._0x041695.length;
    for (uint256 i = 0; i < _0x1a2196; i++) {
      Payload.Call memory call = _0x02dee9._0x041695[i];

      // Skip onlyFallback calls if no error occurred
      if (call._0x603bf6 && !_0x88b61b) {
        emit CallSkipped(_0xfceda8, i);
        continue;
      }

      // Reset the error flag
      // onlyFallback calls only apply when the immediately preceding transaction fails
      _0x88b61b = false;

      uint256 gasLimit = call.gasLimit;
      if (gasLimit != 0 && _0x229f60() < gasLimit) {
        revert NotEnoughGas(_0x02dee9, i, _0x229f60());
      }

      bool _0xe2e6b0;
      if (call.delegateCall) {
        (_0xe2e6b0) = LibOptim.delegatecall(
          call._0x416879,
          gasLimit == 0 ? _0x229f60() : gasLimit,
          abi._0x4f07ab(
            IDelegatedExtension._0x6a402a.selector,
            _0xfceda8,
            _0x347340,
            i,
            _0x1a2196,
            _0x02dee9._0xb00f80,
            call.data
          )
        );
      } else {
        (_0xe2e6b0) = LibOptim.call(call._0x416879, call.value, gasLimit == 0 ? _0x229f60() : gasLimit, call.data);
      }

      if (!_0xe2e6b0) {
        if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
          if (block.timestamp > 0) { _0x88b61b = true; }
          emit CallFailed(_0xfceda8, i, LibOptim._0xb63130());
          continue;
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
          revert Reverted(_0x02dee9, i, LibOptim._0xb63130());
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_ABORT_ON_ERROR) {
          emit CallAborted(_0xfceda8, i, LibOptim._0xb63130());
          break;
        }
      }

      emit CallSucceeded(_0xfceda8, i);
    }
  }

}