// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0x93fc86} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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
  IPoolManager public immutable _0x706a1c;

  constructor(
    IPoolManager _0xe33c29,
    address _0x460807,
    address[] memory _0x6012cb,
    address _0x7455a1,
    address _0x2a32d1
  ) BaseKEMHook(_0x460807, _0x6012cb, _0x7455a1, _0x2a32d1) {
    _0x706a1c = _0xe33c29;
    Hooks._0x9ba2c5(IHooks(address(this)), _0xd04928());
  }

  /// @notice Only allow calls from the PoolManager contract
  modifier _0x3bb945() {
    if (msg.sender != address(_0x706a1c)) revert NotPoolManager();
    _;
  }

  /// @inheritdoc IKEMHook
  function _0xf5b9ed(address[] calldata _0xd26c8c, uint256[] calldata _0x3be2a7) public {
    require(_0xb0f7e6[msg.sender], NonClaimableAccount(msg.sender));
    require(_0xd26c8c.length == _0x3be2a7.length, MismatchedArrayLengths());

    _0x706a1c._0x40bab7(abi._0x1949b4(_0xd26c8c, _0x3be2a7));
  }

  function _0x39270a(bytes calldata data) public _0x3bb945 returns (bytes memory) {
    (address[] memory _0xd26c8c, uint256[] memory _0x3be2a7) = abi._0xcfbdba(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0xd26c8c.length; i++) {
      uint256 _0x3565a8 = uint256(uint160(_0xd26c8c[i]));
      if (_0x3be2a7[i] == 0) {
        _0x3be2a7[i] = _0x706a1c._0x3813cf(address(this), _0x3565a8);
      }
      if (_0x3be2a7[i] > 0) {
        _0x706a1c._0xc084f6(address(this), _0x3565a8, _0x3be2a7[i]);
        _0x706a1c._0x5a159f(Currency._0x7d80ee(_0xd26c8c[i]), _0x049d55, _0x3be2a7[i]);
      }
    }

    emit ClaimEgTokens(_0x049d55, _0xd26c8c, _0x3be2a7);
  }

  function _0xd04928() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0x02364d: false,
      _0xba7e1a: false,
      _0x061978: false,
      _0x072216: false,
      _0xddc849: false,
      _0x3a1055: false,
      _0xf63489: true,
      _0x365da5: true,
      _0x1b4034: false,
      _0x92f394: false,
      _0x6ba9ee: false,
      _0x643dfa: true,
      _0xaf69af: false,
      _0xd3b294: false
    });
  }

  function _0xf63489(
    address sender,
    PoolKey calldata _0x5f9bda,
    IPoolManager.SwapParams calldata _0xe40443,
    bytes calldata _0xbff43e
  ) external _0x3bb945 returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0xe40443._0xdd9983 < 0, ExactOutputDisabled());

    (
      int256 _0xa0770a,
      int256 _0x67e773,
      int256 _0x7de367,
      uint256 _0xec8440,
      uint256 _0x6d576d,
      bytes memory _0x91aa11
    ) = HookDataDecoder._0xcf0828(_0xbff43e);

    require(block.timestamp <= _0x6d576d, ExpiredSignature(_0x6d576d, block.timestamp));
    require(
      -_0xe40443._0xdd9983 <= _0xa0770a,
      ExceededMaxAmountIn(_0xa0770a, -_0xe40443._0xdd9983)
    );

    _0x965486(_0xec8440);

    bytes32 _0xd60904 = _0x9826ce(
      abi._0x1949b4(
        sender,
        _0x5f9bda,
        _0xe40443._0x194947,
        _0xa0770a,
        _0x67e773,
        _0x7de367,
        _0xec8440,
        _0x6d576d
      )
    );
    require(
      SignatureChecker._0x1b8680(_0x8af570, _0xd60904, _0x91aa11), InvalidSignature()
    );

    return (this._0xf63489.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x365da5(
    address,
    PoolKey calldata _0x5f9bda,
    IPoolManager.SwapParams calldata _0xe40443,
    BalanceDelta _0x48f628,
    bytes calldata _0xbff43e
  ) external _0x3bb945 returns (bytes4, int128) {
    (int256 _0x67e773, int256 _0x7de367) =
      HookDataDecoder._0x9b878e(_0xbff43e);

    int128 _0x04c380;
    int128 _0xe2d525;
    Currency _0x8a30ca;
    unchecked {
      if (_0xe40443._0x194947) {
        _0x04c380 = -_0x48f628._0x389a55();
        _0xe2d525 = _0x48f628._0x59b409();
        _0x8a30ca = _0x5f9bda._0x8bb16c;
      } else {
        _0x04c380 = -_0x48f628._0x59b409();
        _0xe2d525 = _0x48f628._0x389a55();
        _0x8a30ca = _0x5f9bda._0x0135ca;
      }
    }

    int256 _0x50bddd = _0x04c380 * _0x67e773 / _0x7de367;

    unchecked {
      int256 _0x5d58a0 = _0x50bddd < _0xe2d525 ? _0xe2d525 - _0x50bddd : int256(0);
      if (_0x5d58a0 > 0) {
        _0x706a1c._0xf7c11a(
          address(this), uint256(uint160(Currency._0x01ac5f(_0x8a30ca))), uint256(_0x5d58a0)
        );

        emit AbsorbEgToken(PoolId._0x01ac5f(_0x5f9bda._0x2f7136()), Currency._0x01ac5f(_0x8a30ca), _0x5d58a0);
      }

      return (this._0x365da5.selector, int128(_0x5d58a0));
    }
  }
}