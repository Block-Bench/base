pragma solidity ^0.8.27;

import { LibOptim } from "../utils/LibOptim.sol";
import { Nonce } from "./Nonce.sol";
import { Payload } from "./Payload.sol";

import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { BaseAuth } from "./auth/BaseAuth.sol";
import { IDelegatedExtension } from "./interfaces/IDelegatedExtension.sol";


abstract contract Calls is ReentrancyGuard, BaseAuth, Nonce {


  event CallSucceeded(bytes32 z, uint256 aa);

  event CallFailed(bytes32 z, uint256 aa, bytes j);

  event CallAborted(bytes32 z, uint256 aa, bytes j);

  event CallSkipped(bytes32 z, uint256 aa);


  error Reverted(Payload.Decoded o, uint256 aa, bytes j);

  error InvalidSignature(Payload.Decoded o, bytes l);

  error NotEnoughGas(Payload.Decoded o, uint256 aa, uint256 p);


  function x(bytes calldata o, bytes calldata l) external payable virtual h {
    uint256 k = w();
    Payload.Decoded memory y = Payload.d(o);

    e(y.ae, y.ac);
    (bool u, bytes32 ab) = b(y, l);

    if (!u) {
      revert InvalidSignature(y, l);
    }

    q(k, ab, y);
  }


  function i(
    bytes calldata o
  ) external payable virtual r {
    uint256 k = w();
    Payload.Decoded memory y = Payload.d(o);
    bytes32 ab = Payload.af(y);
    q(k, ab, y);
  }

  function q(uint256 g, bytes32 z, Payload.Decoded memory t) private {
    bool n = false;

    uint256 s = t.ad.length;
    for (uint256 i = 0; i < s; i++) {
      Payload.Call memory call = t.ad[i];


      if (call.f && !n) {
        emit CallSkipped(z, i);
        continue;
      }


      n = false;

      uint256 gasLimit = call.gasLimit;
      if (gasLimit != 0 && w() < gasLimit) {
        revert NotEnoughGas(t, i, w());
      }

      bool v;
      if (call.delegateCall) {
        (v) = LibOptim.delegatecall(
          call.ag,
          gasLimit == 0 ? w() : gasLimit,
          abi.c(
            IDelegatedExtension.a.selector,
            z,
            g,
            i,
            s,
            t.ae,
            call.data
          )
        );
      } else {
        (v) = LibOptim.call(call.ag, call.value, gasLimit == 0 ? w() : gasLimit, call.data);
      }

      if (!v) {
        if (call.behaviorOnError == Payload.BEHAVIOR_IGNORE_ERROR) {
          n = true;
          emit CallFailed(z, i, LibOptim.m());
          continue;
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_REVERT_ON_ERROR) {
          revert Reverted(t, i, LibOptim.m());
        }

        if (call.behaviorOnError == Payload.BEHAVIOR_ABORT_ON_ERROR) {
          emit CallAborted(z, i, LibOptim.m());
          break;
        }
      }

      emit CallSucceeded(z, i);
    }
  }

}