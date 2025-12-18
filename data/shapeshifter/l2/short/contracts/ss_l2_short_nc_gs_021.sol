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


  IPoolManager public immutable af;

  constructor(
    IPoolManager ad,
    address ab,
    address[] memory c,
    address m,
    address l
  ) BaseKEMHook(ab, c, m, l) {
    af = ad;
    Hooks.d(IHooks(address(this)), o());
  }


  modifier v() {
    if (msg.sender != address(af)) revert NotPoolManager();
    _;
  }


  function z(address[] calldata bh, uint256[] calldata ay) public {
    require(ao[msg.sender], NonClaimableAccount(msg.sender));
    require(bh.length == ay.length, MismatchedArrayLengths());

    af.bc(abi.bb(bh, ay));
  }

  function y(bytes calldata data) public v returns (bytes memory) {
    (address[] memory bh, uint256[] memory ay) = abi.bf(data, (address[], uint256[]));

    for (uint256 i = 0; i < bh.length; i++) {
      uint256 bq = uint256(uint160(bh[i]));
      if (ay[i] == 0) {
        ay[i] = af.at(address(this), bq);
      }
      if (ay[i] > 0) {
        af.bl(address(this), bq, ay[i]);
        af.bn(Currency.bk(bh[i]), ah, ay[i]);
      }
    }

    emit ClaimEgTokens(ah, bh, ay);
  }

  function o() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      s: false,
      u: false,
      j: false,
      q: false,
      e: false,
      g: false,
      am: true,
      aq: true,
      ac: false,
      ai: false,
      f: false,
      h: true,
      b: false,
      a: false
    });
  }

  function am(
    address sender,
    PoolKey calldata bp,
    IPoolManager.SwapParams calldata bd,
    bytes calldata ax
  ) external v returns (bytes4, BeforeSwapDelta, uint24) {
    require(bd.t < 0, ExactOutputDisabled());

    (
      int256 ae,
      int256 w,
      int256 r,
      uint256 bi,
      uint256 ak,
      bytes memory ar
    ) = HookDataDecoder.p(ax);

    require(block.timestamp <= ak, ExpiredSignature(ak, block.timestamp));
    require(
      -bd.t <= ae,
      ExceededMaxAmountIn(ae, -bd.t)
    );

    n(bi);

    bytes32 be = ap(
      abi.bb(
        sender,
        bp,
        bd.al,
        ae,
        w,
        r,
        bi,
        ak
      )
    );
    require(
      SignatureChecker.i(aj, be, ar), InvalidSignature()
    );

    return (this.am.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function aq(
    address,
    PoolKey calldata bp,
    IPoolManager.SwapParams calldata bd,
    BalanceDelta bj,
    bytes calldata ax
  ) external v returns (bytes4, int128) {
    (int256 w, int256 r) =
      HookDataDecoder.k(ax);

    int128 aw;
    int128 au;
    Currency ag;
    unchecked {
      if (bd.al) {
        aw = -bj.az();
        au = bj.ba();
        ag = bp.an;
      } else {
        aw = -bj.ba();
        au = bj.az();
        ag = bp.as;
      }
    }

    int256 aa = aw * w / r;

    unchecked {
      int256 av = aa < au ? au - aa : int256(0);
      if (av > 0) {
        af.bo(
          address(this), uint256(uint160(Currency.bg(ag))), uint256(av)
        );

        emit AbsorbEgToken(PoolId.bg(bp.bm()), Currency.bg(ag), av);
      }

      return (this.aq.selector, int128(av));
    }
  }
}