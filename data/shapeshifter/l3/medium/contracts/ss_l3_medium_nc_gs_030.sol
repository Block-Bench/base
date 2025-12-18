pragma solidity ^0.8.27;

import { LibOptim } from "../utils/LibOptim.sol";
import { Nonce } from "./Nonce.sol";
import { Payload } from "./Payload.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { BaseAuth } from "./auth/BaseAuth.sol";
import { IDelegatedExtension } from "./interfaces/IDelegatedExtension.sol";


abstract contract Calls is ReentrancyGuard, BaseAuth, Nonce {


  event CallSucceeded(bytes32 _0x214810, uint256 _0xe69d03);

  event CallFailed(bytes32 _0x214810, uint256 _0xe69d03, bytes _0xf6807c);

  event CallAborted(bytes32 _0x214810, uint256 _0xe69d03, bytes _0xf6807c);

  event CallSkipped(bytes32 _0x214810, uint256 _0xe69d03);


  error Reverted(Payload.Decoded _0x2bf93f, uint256 _0xe69d03, bytes _0xf6807c);

  error InvalidSignature(Payload.Decoded _0x2bf93f, bytes _0xefb5a9);

  error NotEnoughGas(Payload.Decoded _0x2bf93f, uint256 _0xe69d03, uint256 _0x3b2d72);


  function _0x71f006(bytes calldata _0x2bf93f, bytes calldata _0xefb5a9) external payable virtual _0xe9aabe {
    uint256 _0xa92b6a = _0x3dd680();
    Payload.Decoded memory _0xfade99 = Payload._0xa94641(_0x2bf93f);

    _0x89f96f(_0xfade99._0xd590d5, _0xfade99._0x55c34f);
    (bool _0xef9332, bytes32 _0x7b03bf) = _0x0e3acf(_0xfade99, _0xefb5a9);

    if (!_0xef9332) {
      revert InvalidSignature(_0xfade99, _0xefb5a9);
    }

    _0xca1b1c(_0xa92b6a, _0x7b03bf, _0xfade99);
  }


  function _0xbd1327(
    bytes calldata _0x2bf93f
  ) external payable virtual _0xd7634b {
    uint256 _0xa92b6a = _0x3dd680();
    Payload.Decoded memory _0xfade99 = Payload._0xa94641(_0x2bf93f);
    bytes32 _0x7b03bf = Payload._0x24c5ee(_0xfade99);
    _0xca1b1c(_0xa92b6a, _0x7b03bf, _0xfade99);
  }

  function _0xca1b1c(uint256 _0xa7bd88, bytes32 _0x214810, Payload.Decoded memory _0x655e5c) private {
    bool _0x8d0e5b = false;

    uint256 _0xab513c = _0x655e5c._0x195142.length;
    for (uint256 i = 0; i < _0xab513c; i++) {
      Payload.Call memory call = _0x655e5c._0x195142[i];


      if (call._0xa89c38 && !_0x8d0e5b) {
        emit CallSkipped(_0x214810, i);
        continue;
      }


      _0x8d0e5b = false;

      uint256 gasLimit = call.gasLimit;
      if (gasLimit != 0 && _0x3dd680() < gasLimit) {
        revert NotEnoughGas(_0x655e5c, i, _0x3dd680());
      }

      bool _0xea21ae;
      if (call.delegateCall) {
        (_0xea21ae) = LibOptim.delegatecall(
          call._0xc64875,
          gasLimit == 0 ? _0x3dd680() : gasLimit,
          abi._0x874218(
            IDelegatedExtension._0x642fcf.selector,
            _0x214810,
            _0xa7bd88,
            i,
            _0xab513c,
            _0x655e5c._0xd590d5,
            call.data
          )
        );
      } else {
        (_0xea21ae) = LibOptim.call(call._0xc64875, call.value, gasLimit == 0 ? _0x3dd680() : gasLimit, call.data);
      }

      if (!_0xea21ae) {
        if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
          if (gasleft() > 0) { _0x8d0e5b = true; }
          emit CallFailed(_0x214810, i, LibOptim._0x24d1f3());
          continue;
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
          revert Reverted(_0x655e5c, i, LibOptim._0x24d1f3());
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_ABORT_ON_ERROR) {
          emit CallAborted(_0x214810, i, LibOptim._0x24d1f3());
          break;
        }
      }

      emit CallSucceeded(_0x214810, i);
    }
  }

}