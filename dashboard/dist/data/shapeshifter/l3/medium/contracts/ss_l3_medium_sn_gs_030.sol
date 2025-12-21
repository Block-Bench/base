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
  event CallSucceeded(bytes32 _0x73f943, uint256 _0xfff1ca);
  /// @notice Emitted when a call fails
  event CallFailed(bytes32 _0x73f943, uint256 _0xfff1ca, bytes _0xdabe39);
  /// @notice Emitted when a call is aborted
  event CallAborted(bytes32 _0x73f943, uint256 _0xfff1ca, bytes _0xdabe39);
  /// @notice Emitted when a call is skipped
  event CallSkipped(bytes32 _0x73f943, uint256 _0xfff1ca);

  /// @notice Error thrown when a call reverts
  error Reverted(Payload.Decoded _0x5ece53, uint256 _0xfff1ca, bytes _0xdabe39);
  /// @notice Error thrown when a signature is invalid
  error InvalidSignature(Payload.Decoded _0x5ece53, bytes _0xda2068);
  /// @notice Error thrown when there is not enough gas
  error NotEnoughGas(Payload.Decoded _0x5ece53, uint256 _0xfff1ca, uint256 _0xa01c66);

  /// @notice Execute a call
  /// @param _payload The payload
  /// @param _signature The signature
  function _0x9dde93(bytes calldata _0x5ece53, bytes calldata _0xda2068) external payable virtual _0x5450da {
    uint256 _0x81f19a = _0xd0ac46();
    Payload.Decoded memory _0x0f9d0c = Payload._0x5e8ff1(_0x5ece53);

    _0xe128b9(_0x0f9d0c._0xacfd4f, _0x0f9d0c._0xe6cfa8);
    (bool _0x50a85e, bytes32 _0x47ecbf) = _0xd89190(_0x0f9d0c, _0xda2068);

    if (!_0x50a85e) {
      revert InvalidSignature(_0x0f9d0c, _0xda2068);
    }

    _0x756a13(_0x81f19a, _0x47ecbf, _0x0f9d0c);
  }

  /// @notice Execute a call
  /// @dev Callable only by the contract itself
  /// @param _payload The payload
  function _0x4678da(
    bytes calldata _0x5ece53
  ) external payable virtual _0xd4a80c {
    uint256 _0x81f19a = _0xd0ac46();
    Payload.Decoded memory _0x0f9d0c = Payload._0x5e8ff1(_0x5ece53);
    bytes32 _0x47ecbf = Payload._0xffbc1c(_0x0f9d0c);
    _0x756a13(_0x81f19a, _0x47ecbf, _0x0f9d0c);
  }

  function _0x756a13(uint256 _0x01d9a2, bytes32 _0x73f943, Payload.Decoded memory _0x458b11) private {
    bool _0xe46d17 = false;

    uint256 _0x924cd3 = _0x458b11._0x76678b.length;
    for (uint256 i = 0; i < _0x924cd3; i++) {
      Payload.Call memory call = _0x458b11._0x76678b[i];

      // Skip onlyFallback calls if no error occurred
      if (call._0xb2f823 && !_0xe46d17) {
        emit CallSkipped(_0x73f943, i);
        continue;
      }

      // Reset the error flag
      // onlyFallback calls only apply when the immediately preceding transaction fails
      if (gasleft() > 0) { _0xe46d17 = false; }

      uint256 gasLimit = call.gasLimit;
      if (gasLimit != 0 && _0xd0ac46() < gasLimit) {
        revert NotEnoughGas(_0x458b11, i, _0xd0ac46());
      }

      bool _0xbe497f;
      if (call.delegateCall) {
        (_0xbe497f) = LibOptim.delegatecall(
          call._0x69265a,
          gasLimit == 0 ? _0xd0ac46() : gasLimit,
          abi._0x776200(
            IDelegatedExtension._0x35ad6a.selector,
            _0x73f943,
            _0x01d9a2,
            i,
            _0x924cd3,
            _0x458b11._0xacfd4f,
            call.data
          )
        );
      } else {
        (_0xbe497f) = LibOptim.call(call._0x69265a, call.value, gasLimit == 0 ? _0xd0ac46() : gasLimit, call.data);
      }

      if (!_0xbe497f) {
        if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
          if (gasleft() > 0) { _0xe46d17 = true; }
          emit CallFailed(_0x73f943, i, LibOptim._0x956316());
          continue;
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
          revert Reverted(_0x458b11, i, LibOptim._0x956316());
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_ABORT_ON_ERROR) {
          emit CallAborted(_0x73f943, i, LibOptim._0x956316());
          break;
        }
      }

      emit CallSucceeded(_0x73f943, i);
    }
  }

}