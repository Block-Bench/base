pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, x} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
import {
  BeforeSwapDelta, BeforeSwapDeltaLibrary
} from 'uniswap/v4-core/src/types/BeforeSwapDelta.sol';
import {Currency} from 'uniswap/v4-core/src/types/Currency.sol';
import {PoolId} from 'uniswap/v4-core/src/types/PoolId.sol';
import {PoolKey} from 'uniswap/v4-core/src/types/PoolKey.sol';

import {SignatureChecker} from
  'openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol';


contract UniswapV4KEMHook is BaseKEMHook, IUnlockCallback {

  error NotPoolManager();


  IPoolManager public immutable ah;

  constructor(
    IPoolManager ab,
    address ad,
    address[] memory c,
    address n,
    address k
  ) BaseKEMHook(ad, c, n, k) {
    ah = ab;
    Hooks.d(IHooks(address(this)), j());
  }


  modifier t() {
    if (msg.sender != address(ah)) revert NotPoolManager();
    _;
  }


  function z(address[] calldata bf, uint256[] calldata ay) public {
    require(an[msg.sender], NonClaimableAccount(msg.sender));
    require(bf.length == ay.length, MismatchedArrayLengths());

    ah.bc(abi.bb(bf, ay));
  }

  function y(bytes calldata data) public t returns (bytes memory) {
    (address[] memory bf, uint256[] memory ay) = abi.bh(data, (address[], uint256[]));

    for (uint256 i = 0; i < bf.length; i++) {
      uint256 bq = uint256(uint160(bf[i]));
      if (ay[i] == 0) {
        ay[i] = ah.aq(address(this), bq);
      }
      if (ay[i] > 0) {
        ah.bk(address(this), bq, ay[i]);
        ah.bn(Currency.bl(bf[i]), ag, ay[i]);
      }
    }

    emit ClaimEgTokens(ag, bf, ay);
  }

  function j() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      s: false,
      u: false,
      l: false,
      r: false,
      e: false,
      h: false,
      al: true,
      ar: true,
      aa: false,
      ae: false,
      f: false,
      g: true,
      b: false,
      a: false
    });
  }

  function al(
    address sender,
    PoolKey calldata bp,
    IPoolManager.SwapParams calldata be,
    bytes calldata aw
  ) external t returns (bytes4, BeforeSwapDelta, uint24) {
    require(be.v < 0, ExactOutputDisabled());

    (
      int256 aj,
      int256 w,
      int256 q,
      uint256 bj,
      uint256 ak,
      bytes memory ap
    ) = HookDataDecoder.p(aw);

    require(block.timestamp <= ak, ExpiredSignature(ak, block.timestamp));
    require(
      -be.v <= aj,
      ExceededMaxAmountIn(aj, -be.v)
    );

    m(bj);

    bytes32 bd = as(
      abi.bb(
        sender,
        bp,
        be.am,
        aj,
        w,
        q,
        bj,
        ak
      )
    );
    require(
      SignatureChecker.i(af, bd, ap), InvalidSignature()
    );

    return (this.al.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function ar(
    address,
    PoolKey calldata bp,
    IPoolManager.SwapParams calldata be,
    BalanceDelta bi,
    bytes calldata aw
  ) external t returns (bytes4, int128) {
    (int256 w, int256 q) =
      HookDataDecoder.o(aw);

    int128 ax;
    int128 ao;
    Currency ai;
    unchecked {
      if (be.am) {
        ax = -bi.ba();
        ao = bi.az();
        ai = bp.au;
      } else {
        ax = -bi.az();
        ao = bi.ba();
        ai = bp.at;
      }
    }

    int256 ac = ax * w / q;

    unchecked {
      int256 av = ac < ao ? ao - ac : int256(0);
      if (av > 0) {
        ah.bo(
          address(this), uint256(uint160(Currency.bg(ai))), uint256(av)
        );

        emit AbsorbEgToken(PoolId.bg(bp.bm()), Currency.bg(ai), av);
      }

      return (this.ar.selector, int128(av));
    }
  }
}