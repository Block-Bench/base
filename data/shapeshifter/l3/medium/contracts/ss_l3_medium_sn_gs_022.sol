// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0x3bc4db} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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
  IPoolManager public immutable _0x6305c9;

  constructor(
    IPoolManager _0x52b7ff,
    address _0x529602,
    address[] memory _0xeca3d6,
    address _0xcf0e21,
    address _0x7b970c
  ) BaseKEMHook(_0x529602, _0xeca3d6, _0xcf0e21, _0x7b970c) {
    _0x6305c9 = _0x52b7ff;
    Hooks._0x94f921(IHooks(address(this)), _0x071750());
  }

  /// @notice Only allow calls from the PoolManager contract
  modifier _0xb3ca52() {
    if (msg.sender != address(_0x6305c9)) revert NotPoolManager();
    _;
  }

  /// @inheritdoc IKEMHook
  function _0x4596ee(address[] calldata _0xa922cf, uint256[] calldata _0x1181eb) public {
    require(_0x57dc62[msg.sender], NonClaimableAccount(msg.sender));
    require(_0xa922cf.length == _0x1181eb.length, MismatchedArrayLengths());

    _0x6305c9._0x7ceecd(abi._0xf54462(_0xa922cf, _0x1181eb));
  }

  function _0xc15579(bytes calldata data) public _0xb3ca52 returns (bytes memory) {
    (address[] memory _0xa922cf, uint256[] memory _0x1181eb) = abi._0xfc05e9(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0xa922cf.length; i++) {
      uint256 _0x4d5ccf = uint256(uint160(_0xa922cf[i]));
      if (_0x1181eb[i] == 0) {
        _0x1181eb[i] = _0x6305c9._0xa00f21(address(this), _0x4d5ccf);
      }
      if (_0x1181eb[i] > 0) {
        _0x6305c9._0x6d4e7e(address(this), _0x4d5ccf, _0x1181eb[i]);
        _0x6305c9._0x3a40a1(Currency._0xd3f3f3(_0xa922cf[i]), _0x17e827, _0x1181eb[i]);
      }
    }

    emit ClaimEgTokens(_0x17e827, _0xa922cf, _0x1181eb);
  }

  function _0x071750() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0x10a4a9: false,
      _0xd614a3: false,
      _0xd63281: false,
      _0x780e9b: false,
      _0xc98922: false,
      _0x7a45ed: false,
      _0xbab8eb: true,
      _0x5d9cbe: true,
      _0xa8ce09: false,
      _0x046544: false,
      _0x4032c8: false,
      _0x308888: true,
      _0x81f6d8: false,
      _0x2cc5e1: false
    });
  }

  function _0xbab8eb(
    address sender,
    PoolKey calldata _0x061994,
    IPoolManager.SwapParams calldata _0xc126d1,
    bytes calldata _0x25fb5d
  ) external _0xb3ca52 returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0xc126d1._0x814027 < 0, ExactOutputDisabled());

    (
      int256 _0x40c6ca,
      int256 _0x16524e,
      int256 _0x9e449b,
      uint256 _0xc9a97b,
      uint256 _0x18784b,
      bytes memory _0x6cacb8
    ) = HookDataDecoder._0x288c41(_0x25fb5d);

    require(block.timestamp <= _0x18784b, ExpiredSignature(_0x18784b, block.timestamp));
    require(
      -_0xc126d1._0x814027 <= _0x40c6ca,
      ExceededMaxAmountIn(_0x40c6ca, -_0xc126d1._0x814027)
    );

    _0x8d457d(_0xc9a97b);

    bytes32 _0x90233a = _0x1a76cc(
      abi._0xf54462(
        sender,
        _0x061994,
        _0xc126d1._0xef77d2,
        _0x40c6ca,
        _0x16524e,
        _0x9e449b,
        _0xc9a97b,
        _0x18784b
      )
    );
    require(
      SignatureChecker._0x125740(_0xa3d99d, _0x90233a, _0x6cacb8), InvalidSignature()
    );

    return (this._0xbab8eb.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x5d9cbe(
    address,
    PoolKey calldata _0x061994,
    IPoolManager.SwapParams calldata _0xc126d1,
    BalanceDelta _0xacffa4,
    bytes calldata _0x25fb5d
  ) external _0xb3ca52 returns (bytes4, int128) {
    (int256 _0x16524e, int256 _0x9e449b) =
      HookDataDecoder._0x26630a(_0x25fb5d);

    int128 _0x397325;
    int128 _0xe103a1;
    Currency _0x2aef3a;
    unchecked {
      if (_0xc126d1._0xef77d2) {
        _0x397325 = -_0xacffa4._0xc70a7b();
        _0xe103a1 = _0xacffa4._0xf94e4b();
        _0x2aef3a = _0x061994._0xb3c0a4;
      } else {
        _0x397325 = -_0xacffa4._0xf94e4b();
        _0xe103a1 = _0xacffa4._0xc70a7b();
        _0x2aef3a = _0x061994._0xb81f20;
      }
    }

    int256 _0x01c3cb = _0x397325 * _0x16524e / _0x9e449b;

    unchecked {
      int256 _0x526bdf = _0x01c3cb < _0xe103a1 ? _0xe103a1 - _0x01c3cb : int256(0);
      if (_0x526bdf > 0) {
        _0x6305c9._0xa95c3a(
          address(this), uint256(uint160(Currency._0xe6dccb(_0x2aef3a))), uint256(_0x526bdf)
        );

        emit AbsorbEgToken(PoolId._0xe6dccb(_0x061994._0x77d01e()), Currency._0xe6dccb(_0x2aef3a), _0x526bdf);
      }

      return (this._0x5d9cbe.selector, int128(_0x526bdf));
    }
  }
}