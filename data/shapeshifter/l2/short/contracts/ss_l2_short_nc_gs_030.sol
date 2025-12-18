pragma solidity ^0.8.27;

import { LibOptim } from "../utils/LibOptim.sol";
import { Nonce } from "./Nonce.sol";
import { Payload } from "./Payload.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { BaseAuth } from "./auth/BaseAuth.sol";
import { IDelegatedExtension } from "./interfaces/IDelegatedExtension.sol";


abstract contract Calls is ReentrancyGuard, BaseAuth, Nonce {


  event CallSucceeded(bytes32 v, uint256 ab);

  event CallFailed(bytes32 v, uint256 ab, bytes j);

  event CallAborted(bytes32 v, uint256 ab, bytes j);

  event CallSkipped(bytes32 v, uint256 ab);


  error Reverted(Payload.Decoded s, uint256 ab, bytes j);

  error InvalidSignature(Payload.Decoded s, bytes l);

  error NotEnoughGas(Payload.Decoded s, uint256 ab, uint256 r);


  function u(bytes calldata s, bytes calldata l) external payable virtual h {
    uint256 k = y();
    Payload.Decoded memory x = Payload.d(s);

    e(x.ac, x.ad);
    (bool z, bytes32 aa) = b(x, l);

    if (!z) {
      revert InvalidSignature(x, l);
    }

    t(k, aa, x);
  }


  function i(
    bytes calldata s
  ) external payable virtual p {
    uint256 k = y();
    Payload.Decoded memory x = Payload.d(s);
    bytes32 aa = Payload.af(x);
    t(k, aa, x);
  }

  function t(uint256 g, bytes32 v, Payload.Decoded memory q) private {
    bool n = false;

    uint256 o = q.ae.length;
    for (uint256 i = 0; i < o; i++) {
      Payload.Call memory call = q.ae[i];


      if (call.f && !n) {
        emit CallSkipped(v, i);
        continue;
      }


      n = false;

      uint256 gasLimit = call.gasLimit;
      if (gasLimit != 0 && y() < gasLimit) {
        revert NotEnoughGas(q, i, y());
      }

      bool w;
      if (call.delegateCall) {
        (w) = LibOptim.delegatecall(
          call.ag,
          gasLimit == 0 ? y() : gasLimit,
          abi.c(
            IDelegatedExtension.a.selector,
            v,
            g,
            i,
            o,
            q.ac,
            call.data
          )
        );
      } else {
        (w) = LibOptim.call(call.ag, call.value, gasLimit == 0 ? y() : gasLimit, call.data);
      }

      if (!w) {
        if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
          n = true;
          emit CallFailed(v, i, LibOptim.m());
          continue;
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
          revert Reverted(q, i, LibOptim.m());
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