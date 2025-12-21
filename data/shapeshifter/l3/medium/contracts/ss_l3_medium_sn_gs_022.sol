// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0x5f3fb9} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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
  IPoolManager public immutable _0x326eed;

  constructor(
    IPoolManager _0xb09222,
    address _0xcfe420,
    address[] memory _0x3e64a9,
    address _0x0caeab,
    address _0x4acdd7
  ) BaseKEMHook(_0xcfe420, _0x3e64a9, _0x0caeab, _0x4acdd7) {
    _0x326eed = _0xb09222;
    Hooks._0xed6aed(IHooks(address(this)), _0x9a0f3e());
  }

  /// @notice Only allow calls from the PoolManager contract
  modifier _0x9673c6() {
    if (msg.sender != address(_0x326eed)) revert NotPoolManager();
    _;
  }

  /// @inheritdoc IKEMHook
  function _0x84df3f(address[] calldata _0x67624f, uint256[] calldata _0x45e8f5) public {
    require(_0x5f57b8[msg.sender], NonClaimableAccount(msg.sender));
    require(_0x67624f.length == _0x45e8f5.length, MismatchedArrayLengths());

    _0x326eed._0x75fbb1(abi._0x4f7d11(_0x67624f, _0x45e8f5));
  }

  function _0x042376(bytes calldata data) public _0x9673c6 returns (bytes memory) {
    (address[] memory _0x67624f, uint256[] memory _0x45e8f5) = abi._0xa9f4d6(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0x67624f.length; i++) {
      uint256 _0x6231fc = uint256(uint160(_0x67624f[i]));
      if (_0x45e8f5[i] == 0) {
        _0x45e8f5[i] = _0x326eed._0x74a05a(address(this), _0x6231fc);
      }
      if (_0x45e8f5[i] > 0) {
        _0x326eed._0x9bebb8(address(this), _0x6231fc, _0x45e8f5[i]);
        _0x326eed._0x586912(Currency._0xda4a3c(_0x67624f[i]), _0x517cee, _0x45e8f5[i]);
      }
    }

    emit ClaimEgTokens(_0x517cee, _0x67624f, _0x45e8f5);
  }

  function _0x9a0f3e() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0x664bc0: false,
      _0xaeb7fe: false,
      _0xd9e8d7: false,
      _0x97ef82: false,
      _0xd25ecc: false,
      _0x9a6b4f: false,
      _0x42a0dd: true,
      _0x5a7ca1: true,
      _0xc3ad19: false,
      _0xcc1de2: false,
      _0xdeea37: false,
      _0xcaaaa2: true,
      _0x273f9e: false,
      _0xf3f436: false
    });
  }

  function _0x42a0dd(
    address sender,
    PoolKey calldata _0x29167c,
    IPoolManager.SwapParams calldata _0xa2622d,
    bytes calldata _0x86e5dd
  ) external _0x9673c6 returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0xa2622d._0x0418bc < 0, ExactOutputDisabled());

    (
      int256 _0xa581ce,
      int256 _0x625eb0,
      int256 _0xcc8f73,
      uint256 _0xc31520,
      uint256 _0xa253ff,
      bytes memory _0x06939a
    ) = HookDataDecoder._0x515294(_0x86e5dd);

    require(block.timestamp <= _0xa253ff, ExpiredSignature(_0xa253ff, block.timestamp));
    require(
      -_0xa2622d._0x0418bc <= _0xa581ce,
      ExceededMaxAmountIn(_0xa581ce, -_0xa2622d._0x0418bc)
    );

    _0xfa3b0a(_0xc31520);

    bytes32 _0x101872 = _0x465e1a(
      abi._0x4f7d11(
        sender,
        _0x29167c,
        _0xa2622d._0xedc681,
        _0xa581ce,
        _0x625eb0,
        _0xcc8f73,
        _0xc31520,
        _0xa253ff
      )
    );
    require(
      SignatureChecker._0xcd3cf7(_0x05a5ed, _0x101872, _0x06939a), InvalidSignature()
    );

    return (this._0x42a0dd.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x5a7ca1(
    address,
    PoolKey calldata _0x29167c,
    IPoolManager.SwapParams calldata _0xa2622d,
    BalanceDelta _0xbd540b,
    bytes calldata _0x86e5dd
  ) external _0x9673c6 returns (bytes4, int128) {
    (int256 _0x625eb0, int256 _0xcc8f73) =
      HookDataDecoder._0xd30781(_0x86e5dd);

    int128 _0x293e8a;
    int128 _0x7c57b2;
    Currency _0x8ee5d4;
    unchecked {
      if (_0xa2622d._0xedc681) {
        _0x293e8a = -_0xbd540b._0x0ad294();
        _0x7c57b2 = _0xbd540b._0xeb01a1();
        _0x8ee5d4 = _0x29167c._0x3b2a41;
      } else {
        _0x293e8a = -_0xbd540b._0xeb01a1();
        _0x7c57b2 = _0xbd540b._0x0ad294();
        _0x8ee5d4 = _0x29167c._0x10c2cf;
      }
    }

    int256 _0x8e67d5 = _0x293e8a * _0x625eb0 / _0xcc8f73;

    unchecked {
      int256 _0xdfbda4 = _0x8e67d5 < _0x7c57b2 ? _0x7c57b2 - _0x8e67d5 : int256(0);
      if (_0xdfbda4 > 0) {
        _0x326eed._0xb3d19c(
          address(this), uint256(uint160(Currency._0x092df4(_0x8ee5d4))), uint256(_0xdfbda4)
        );

        emit AbsorbEgToken(PoolId._0x092df4(_0x29167c._0x681fe9()), Currency._0x092df4(_0x8ee5d4), _0xdfbda4);
      }

      return (this._0x5a7ca1.selector, int128(_0xdfbda4));
    }
  }
}