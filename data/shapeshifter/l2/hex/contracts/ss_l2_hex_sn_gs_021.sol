// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0xa4e47f} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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
  IPoolManager public immutable _0x691fdd;

  constructor(
    IPoolManager _0xe42236,
    address _0xc7bdcb,
    address[] memory _0x9daa21,
    address _0x375f13,
    address _0xa990c6
  ) BaseKEMHook(_0xc7bdcb, _0x9daa21, _0x375f13, _0xa990c6) {
    _0x691fdd = _0xe42236;
    Hooks._0x2ac932(IHooks(address(this)), _0x0ed9e4());
  }

  /// @notice Only allow calls from the PoolManager contract
  modifier _0x38eaae() {
    if (msg.sender != address(_0x691fdd)) revert NotPoolManager();
    _;
  }

  /// @inheritdoc IKEMHook
  function _0x3113da(address[] calldata _0x2b79d6, uint256[] calldata _0x06fb7f) public {
    require(_0xf1dcb6[msg.sender], NonClaimableAccount(msg.sender));
    require(_0x2b79d6.length == _0x06fb7f.length, MismatchedArrayLengths());

    _0x691fdd._0xb2b7a7(abi._0x003305(_0x2b79d6, _0x06fb7f));
  }

  function _0x85e928(bytes calldata data) public _0x38eaae returns (bytes memory) {
    (address[] memory _0x2b79d6, uint256[] memory _0x06fb7f) = abi._0x171028(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0x2b79d6.length; i++) {
      uint256 _0x5ec077 = uint256(uint160(_0x2b79d6[i]));
      if (_0x06fb7f[i] == 0) {
        _0x06fb7f[i] = _0x691fdd._0x540a54(address(this), _0x5ec077);
      }
      if (_0x06fb7f[i] > 0) {
        _0x691fdd._0x1c7319(address(this), _0x5ec077, _0x06fb7f[i]);
        _0x691fdd._0x2b637b(Currency._0xa40d2f(_0x2b79d6[i]), _0x9747ef, _0x06fb7f[i]);
      }
    }

    emit ClaimEgTokens(_0x9747ef, _0x2b79d6, _0x06fb7f);
  }

  function _0x0ed9e4() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0x3a74c8: false,
      _0x6e73c7: false,
      _0xf226a8: false,
      _0x6339c8: false,
      _0x47526e: false,
      _0xba470f: false,
      _0x73c8e9: true,
      _0x5c4ec1: true,
      _0x02c839: false,
      _0x0dd3cc: false,
      _0x23b00f: false,
      _0x973746: true,
      _0xc8fb1f: false,
      _0x7d162e: false
    });
  }

  function _0x73c8e9(
    address sender,
    PoolKey calldata _0xaabff5,
    IPoolManager.SwapParams calldata _0x4f56a1,
    bytes calldata _0x163071
  ) external _0x38eaae returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0x4f56a1._0x9754ab < 0, ExactOutputDisabled());

    (
      int256 _0x28310e,
      int256 _0x114684,
      int256 _0x81f0ef,
      uint256 _0x4cad1e,
      uint256 _0x191a63,
      bytes memory _0xfc4b19
    ) = HookDataDecoder._0x1c7857(_0x163071);

    require(block.timestamp <= _0x191a63, ExpiredSignature(_0x191a63, block.timestamp));
    require(
      -_0x4f56a1._0x9754ab <= _0x28310e,
      ExceededMaxAmountIn(_0x28310e, -_0x4f56a1._0x9754ab)
    );

    _0x3e0161(_0x4cad1e);

    bytes32 _0xf6291f = _0xa1e2ee(
      abi._0x003305(
        sender,
        _0xaabff5,
        _0x4f56a1._0xfcd8a5,
        _0x28310e,
        _0x114684,
        _0x81f0ef,
        _0x4cad1e,
        _0x191a63
      )
    );
    require(
      SignatureChecker._0x467ee0(_0x932e1f, _0xf6291f, _0xfc4b19), InvalidSignature()
    );

    return (this._0x73c8e9.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x5c4ec1(
    address,
    PoolKey calldata _0xaabff5,
    IPoolManager.SwapParams calldata _0x4f56a1,
    BalanceDelta _0x0f7a29,
    bytes calldata _0x163071
  ) external _0x38eaae returns (bytes4, int128) {
    (int256 _0x114684, int256 _0x81f0ef) =
      HookDataDecoder._0x50496a(_0x163071);

    int128 _0x7c7c48;
    int128 _0xed4f26;
    Currency _0xfac989;
    unchecked {
      if (_0x4f56a1._0xfcd8a5) {
        _0x7c7c48 = -_0x0f7a29._0x11e689();
        _0xed4f26 = _0x0f7a29._0x6e4b04();
        _0xfac989 = _0xaabff5._0xf09ae0;
      } else {
        _0x7c7c48 = -_0x0f7a29._0x6e4b04();
        _0xed4f26 = _0x0f7a29._0x11e689();
        _0xfac989 = _0xaabff5._0xfb0c08;
      }
    }

    int256 _0x64f662 = _0x7c7c48 * _0x114684 / _0x81f0ef;

    unchecked {
      int256 _0x32cbbf = _0x64f662 < _0xed4f26 ? _0xed4f26 - _0x64f662 : int256(0);
      if (_0x32cbbf > 0) {
        _0x691fdd._0x4a5d7c(
          address(this), uint256(uint160(Currency._0xa9532b(_0xfac989))), uint256(_0x32cbbf)
        );

        emit AbsorbEgToken(PoolId._0xa9532b(_0xaabff5._0x26a070()), Currency._0xa9532b(_0xfac989), _0x32cbbf);
      }

      return (this._0x5c4ec1.selector, int128(_0x32cbbf));
    }
  }
}