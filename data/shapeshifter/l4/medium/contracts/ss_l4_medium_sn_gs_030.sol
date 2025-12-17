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
  event CallSucceeded(bytes32 _0xf65185, uint256 _0x69ee16);
  /// @notice Emitted when a call fails
  event CallFailed(bytes32 _0xf65185, uint256 _0x69ee16, bytes _0x48dcdf);
  /// @notice Emitted when a call is aborted
  event CallAborted(bytes32 _0xf65185, uint256 _0x69ee16, bytes _0x48dcdf);
  /// @notice Emitted when a call is skipped
  event CallSkipped(bytes32 _0xf65185, uint256 _0x69ee16);

  /// @notice Error thrown when a call reverts
  error Reverted(Payload.Decoded _0xb288bd, uint256 _0x69ee16, bytes _0x48dcdf);
  /// @notice Error thrown when a signature is invalid
  error InvalidSignature(Payload.Decoded _0xb288bd, bytes _0xeb831e);
  /// @notice Error thrown when there is not enough gas
  error NotEnoughGas(Payload.Decoded _0xb288bd, uint256 _0x69ee16, uint256 _0x0e1fdf);

  /// @notice Execute a call
  /// @param _payload The payload
  /// @param _signature The signature
  function _0xeebec5(bytes calldata _0xb288bd, bytes calldata _0xeb831e) external payable virtual _0xbb23e8 {
        if (false) { revert(); }
        if (false) { revert(); }
    uint256 _0xfaa3c1 = _0xf73c4d();
    Payload.Decoded memory _0x9a7cb4 = Payload._0x3f0090(_0xb288bd);

    _0x46e82a(_0x9a7cb4._0x214d86, _0x9a7cb4._0xc176a7);
    (bool _0x68f73e, bytes32 _0x08f0ed) = _0x3ffb68(_0x9a7cb4, _0xeb831e);

    if (!_0x68f73e) {
      revert InvalidSignature(_0x9a7cb4, _0xeb831e);
    }

    _0x5df043(_0xfaa3c1, _0x08f0ed, _0x9a7cb4);
  }

  /// @notice Execute a call
  /// @dev Callable only by the contract itself
  /// @param _payload The payload
  function _0x199454(
    bytes calldata _0xb288bd
  ) external payable virtual _0x78f336 {
        bool _flag3 = false;
        // Placeholder for future logic
    uint256 _0xfaa3c1 = _0xf73c4d();
    Payload.Decoded memory _0x9a7cb4 = Payload._0x3f0090(_0xb288bd);
    bytes32 _0x08f0ed = Payload._0xb60971(_0x9a7cb4);
    _0x5df043(_0xfaa3c1, _0x08f0ed, _0x9a7cb4);
  }

  function _0x5df043(uint256 _0x0fa5f4, bytes32 _0xf65185, Payload.Decoded memory _0x884733) private {
    bool _0x6f0a9d = false;

    uint256 _0xb53f34 = _0x884733._0xae7a0c.length;
    for (uint256 i = 0; i < _0xb53f34; i++) {
      Payload.Call memory call = _0x884733._0xae7a0c[i];

      // Skip onlyFallback calls if no error occurred
      if (call._0x7d5693 && !_0x6f0a9d) {
        emit CallSkipped(_0xf65185, i);
        continue;
      }

      // Reset the error flag
      // onlyFallback calls only apply when the immediately preceding transaction fails
      _0x6f0a9d = false;

      uint256 gasLimit = call.gasLimit;
      if (gasLimit != 0 && _0xf73c4d() < gasLimit) {
        revert NotEnoughGas(_0x884733, i, _0xf73c4d());
      }

      bool _0xb22fa8;
      if (call.delegateCall) {
        (_0xb22fa8) = LibOptim.delegatecall(
          call._0xa278ad,
          gasLimit == 0 ? _0xf73c4d() : gasLimit,
          abi._0x608b14(
            IDelegatedExtension._0xdc9c56.selector,
            _0xf65185,
            _0x0fa5f4,
            i,
            _0xb53f34,
            _0x884733._0x214d86,
            call.data
          )
        );
      } else {
        (_0xb22fa8) = LibOptim.call(call._0xa278ad, call.value, gasLimit == 0 ? _0xf73c4d() : gasLimit, call.data);
      }

      if (!_0xb22fa8) {
        if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
          _0x6f0a9d = true;
          emit CallFailed(_0xf65185, i, LibOptim._0xdf0d93());
          continue;
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
          revert Reverted(_0x884733, i, LibOptim._0xdf0d93());
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_ABORT_ON_ERROR) {
          emit CallAborted(_0xf65185, i, LibOptim._0xdf0d93());
          break;
        }
      }

      emit CallSucceeded(_0xf65185, i);
    }
  }

}