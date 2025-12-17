// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0xdd5899} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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
  IPoolManager public immutable _0x80114e;

  constructor(
    IPoolManager _0x908071,
    address _0x495903,
    address[] memory _0x950e02,
    address _0x4bf1dd,
    address _0xd39fdc
  ) BaseKEMHook(_0x495903, _0x950e02, _0x4bf1dd, _0xd39fdc) {
    _0x80114e = _0x908071;
    Hooks._0xcab88f(IHooks(address(this)), _0xccd6ab());
  }

  /// @notice Only allow calls from the PoolManager contract
  modifier _0x2c07e3() {
    if (msg.sender != address(_0x80114e)) revert NotPoolManager();
    _;
  }

  /// @inheritdoc IKEMHook
  function _0x09a530(address[] calldata _0x6a6517, uint256[] calldata _0xbd5104) public {
    require(_0xa2eb9a[msg.sender], NonClaimableAccount(msg.sender));
    require(_0x6a6517.length == _0xbd5104.length, MismatchedArrayLengths());

    _0x80114e._0xa2a129(abi._0x34c0da(_0x6a6517, _0xbd5104));
  }

  function _0x2c69aa(bytes calldata data) public _0x2c07e3 returns (bytes memory) {
    (address[] memory _0x6a6517, uint256[] memory _0xbd5104) = abi._0x1bdb39(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0x6a6517.length; i++) {
      uint256 _0xff3eed = uint256(uint160(_0x6a6517[i]));
      if (_0xbd5104[i] == 0) {
        _0xbd5104[i] = _0x80114e._0x56a236(address(this), _0xff3eed);
      }
      if (_0xbd5104[i] > 0) {
        _0x80114e._0x2ce019(address(this), _0xff3eed, _0xbd5104[i]);
        _0x80114e._0xcae791(Currency._0x81ecaa(_0x6a6517[i]), _0x8752eb, _0xbd5104[i]);
      }
    }

    emit ClaimEgTokens(_0x8752eb, _0x6a6517, _0xbd5104);
  }

  function _0xccd6ab() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0xffa7eb: false,
      _0xa57f5c: false,
      _0x5ea0cc: false,
      _0xdf556e: false,
      _0x71fe41: false,
      _0x07f29e: false,
      _0x14e49d: true,
      _0xbf049c: true,
      _0x1a5702: false,
      _0xdee784: false,
      _0x9070b4: false,
      _0xb2bc6f: true,
      _0xfd1b88: false,
      _0xe3a3d0: false
    });
  }

  function _0x14e49d(
    address sender,
    PoolKey calldata _0x3a8769,
    IPoolManager.SwapParams calldata _0x5b739a,
    bytes calldata _0x0762e0
  ) external _0x2c07e3 returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0x5b739a._0xbc26e8 < 0, ExactOutputDisabled());

    (
      int256 _0x95d803,
      int256 _0x5bc42b,
      int256 _0x6edb05,
      uint256 _0x23205c,
      uint256 _0xb32b5c,
      bytes memory _0x10c0c1
    ) = HookDataDecoder._0x9f29f9(_0x0762e0);

    require(block.timestamp <= _0xb32b5c, ExpiredSignature(_0xb32b5c, block.timestamp));
    require(
      -_0x5b739a._0xbc26e8 <= _0x95d803,
      ExceededMaxAmountIn(_0x95d803, -_0x5b739a._0xbc26e8)
    );

    _0x101b2b(_0x23205c);

    bytes32 _0x1d960c = _0x4a4969(
      abi._0x34c0da(
        sender,
        _0x3a8769,
        _0x5b739a._0x0b6d87,
        _0x95d803,
        _0x5bc42b,
        _0x6edb05,
        _0x23205c,
        _0xb32b5c
      )
    );
    require(
      SignatureChecker._0x52dc30(_0xfacb0d, _0x1d960c, _0x10c0c1), InvalidSignature()
    );

    return (this._0x14e49d.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0xbf049c(
    address,
    PoolKey calldata _0x3a8769,
    IPoolManager.SwapParams calldata _0x5b739a,
    BalanceDelta _0xdb012c,
    bytes calldata _0x0762e0
  ) external _0x2c07e3 returns (bytes4, int128) {
    (int256 _0x5bc42b, int256 _0x6edb05) =
      HookDataDecoder._0xf63c72(_0x0762e0);

    int128 _0xcbfa10;
    int128 _0x06e9fa;
    Currency _0x74b67b;
    unchecked {
      if (_0x5b739a._0x0b6d87) {
        _0xcbfa10 = -_0xdb012c._0x17c980();
        _0x06e9fa = _0xdb012c._0x264a74();
        _0x74b67b = _0x3a8769._0x8529c6;
      } else {
        _0xcbfa10 = -_0xdb012c._0x264a74();
        _0x06e9fa = _0xdb012c._0x17c980();
        _0x74b67b = _0x3a8769._0xeba475;
      }
    }

    int256 _0x4f9c36 = _0xcbfa10 * _0x5bc42b / _0x6edb05;

    unchecked {
      int256 _0xc58628 = _0x4f9c36 < _0x06e9fa ? _0x06e9fa - _0x4f9c36 : int256(0);
      if (_0xc58628 > 0) {
        _0x80114e._0x29ed74(
          address(this), uint256(uint160(Currency._0xdca3cb(_0x74b67b))), uint256(_0xc58628)
        );

        emit AbsorbEgToken(PoolId._0xdca3cb(_0x3a8769._0x729cab()), Currency._0xdca3cb(_0x74b67b), _0xc58628);
      }

      return (this._0xbf049c.selector, int128(_0xc58628));
    }
  }
}