// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, y} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
import {
  BeforeSwapDelta, BeforeSwapDeltaLibrary
} from 'uniswap/v4-core/src/types/BeforeSwapDelta.sol';
import {Currency} from 'uniswap/v4-core/src/types/Currency.sol';
import {PoolId} from 'uniswap/v4-core/src/types/PoolId.sol';
import {PoolKey} from 'uniswap/v4-core/src/types/PoolKey.sol';

import {SignatureChecker} from
  'openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol';

/// @title UniswapV4KEMHook
contract UniswapV4KEMHook is BaseKEMHook, IUnlockCallback {
  /// @notice Thrown when the caller is not PoolManager
  error NotPoolManager();

  /// @notice The address of the PoolManager contract
  IPoolManager public immutable ag;

  constructor(
    IPoolManager ac,
    address ab,
    address[] memory c,
    address j,
    address l
  ) BaseKEMHook(ab, c, j, l) {
    ag = ac;
    Hooks.d(IHooks(address(this)), k());
  }

  /// @notice Only allow calls from the PoolManager contract
  modifier u() {
    if (msg.sender != address(ag)) revert NotPoolManager();
    _;
  }

  /// @inheritdoc IKEMHook
  function z(address[] calldata bb, uint256[] calldata ay) public {
    require(at[msg.sender], NonClaimableAccount(msg.sender));
    require(bb.length == ay.length, MismatchedArrayLengths());

    ag.bf(abi.be(bb, ay));
  }

  function x(bytes calldata data) public u returns (bytes memory) {
    (address[] memory bb, uint256[] memory ay) = abi.bh(data, (address[], uint256[]));

    for (uint256 i = 0; i < bb.length; i++) {
      uint256 bq = uint256(uint160(bb[i]));
      if (ay[i] == 0) {
        ay[i] = ag.ao(address(this), bq);
      }
      if (ay[i] > 0) {
        ag.bn(address(this), bq, ay[i]);
        ag.bm(Currency.bl(bb[i]), ah, ay[i]);
      }
    }

    emit ClaimEgTokens(ah, bb, ay);
  }

  function k() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      s: false,
      t: false,
      o: false,
      r: false,
      f: false,
      g: false,
      al: true,
      ar: true,
      aa: false,
      ai: false,
      e: false,
      h: true,
      b: false,
      a: false
    });
  }

  function al(
    address sender,
    PoolKey calldata bp,
    IPoolManager.SwapParams calldata bd,
    bytes calldata ax
  ) external u returns (bytes4, BeforeSwapDelta, uint24) {
    require(bd.w < 0, ExactOutputDisabled());

    (
      int256 af,
      int256 v,
      int256 q,
      uint256 bi,
      uint256 ak,
      bytes memory au
    ) = HookDataDecoder.p(ax);

    require(block.timestamp <= ak, ExpiredSignature(ak, block.timestamp));
    require(
      -bd.w <= af,
      ExceededMaxAmountIn(af, -bd.w)
    );

    m(bi);

    bytes32 bg = as(
      abi.be(
        sender,
        bp,
        bd.am,
        af,
        v,
        q,
        bi,
        ak
      )
    );
    require(
      SignatureChecker.i(ae, bg, au), InvalidSignature()
    );

    return (this.al.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function ar(
    address,
    PoolKey calldata bp,
    IPoolManager.SwapParams calldata bd,
    BalanceDelta bj,
    bytes calldata ax
  ) external u returns (bytes4, int128) {
    (int256 v, int256 q) =
      HookDataDecoder.n(ax);

    int128 av;
    int128 ap;
    Currency aj;
    unchecked {
      if (bd.am) {
        av = -bj.az();
        ap = bj.ba();
        aj = bp.an;
      } else {
        av = -bj.ba();
        ap = bj.az();
        aj = bp.aq;
      }
    }

    int256 ad = av * v / q;

    unchecked {
      int256 aw = ad < ap ? ap - ad : int256(0);
      if (aw > 0) {
        ag.bk(
          address(this), uint256(uint160(Currency.bc(aj))), uint256(aw)
        );

        emit AbsorbEgToken(PoolId.bc(bp.bo()), Currency.bc(aj), aw);
      }

      return (this.ar.selector, int128(aw));
    }
  }
}