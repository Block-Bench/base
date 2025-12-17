// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0x0e1337} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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
  IPoolManager public immutable _0xabe670;

  constructor(
    IPoolManager _0x634a97,
    address _0xa7cd95,
    address[] memory _0xabbadb,
    address _0x01e6f8,
    address _0x034bbf
  ) BaseKEMHook(_0xa7cd95, _0xabbadb, _0x01e6f8, _0x034bbf) {
    _0xabe670 = _0x634a97;
    Hooks._0x41ea10(IHooks(address(this)), _0x277c83());
  }

  /// @notice Only allow calls from the PoolManager contract
  modifier _0xa729f9() {
    if (msg.sender != address(_0xabe670)) revert NotPoolManager();
    _;
  }

  /// @inheritdoc IKEMHook
  function _0x61c671(address[] calldata _0x679601, uint256[] calldata _0x01b1b8) public {
    require(_0xfcb723[msg.sender], NonClaimableAccount(msg.sender));
    require(_0x679601.length == _0x01b1b8.length, MismatchedArrayLengths());

    _0xabe670._0xe61dd4(abi._0x50622a(_0x679601, _0x01b1b8));
  }

  function _0xf4da36(bytes calldata data) public _0xa729f9 returns (bytes memory) {
    (address[] memory _0x679601, uint256[] memory _0x01b1b8) = abi._0x5da861(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0x679601.length; i++) {
      uint256 _0x0bdd49 = uint256(uint160(_0x679601[i]));
      if (_0x01b1b8[i] == 0) {
        _0x01b1b8[i] = _0xabe670._0x5cb76f(address(this), _0x0bdd49);
      }
      if (_0x01b1b8[i] > 0) {
        _0xabe670._0x69b6b4(address(this), _0x0bdd49, _0x01b1b8[i]);
        _0xabe670._0x7b7591(Currency._0xde5628(_0x679601[i]), _0x2c9166, _0x01b1b8[i]);
      }
    }

    emit ClaimEgTokens(_0x2c9166, _0x679601, _0x01b1b8);
  }

  function _0x277c83() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0xeec954: false,
      _0x93344e: false,
      _0xb08d91: false,
      _0xf582c2: false,
      _0xc44b54: false,
      _0x21095e: false,
      _0x8f2088: true,
      _0x562e89: true,
      _0xff023b: false,
      _0x622d74: false,
      _0x55de3c: false,
      _0xf19cdc: true,
      _0xa0c49f: false,
      _0x43a42c: false
    });
  }

  function _0x8f2088(
    address sender,
    PoolKey calldata _0x1d2a8e,
    IPoolManager.SwapParams calldata _0x31bb60,
    bytes calldata _0x3da71a
  ) external _0xa729f9 returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0x31bb60._0x9bb2f6 < 0, ExactOutputDisabled());

    (
      int256 _0x15f909,
      int256 _0xf94514,
      int256 _0x5341b8,
      uint256 _0x159b0b,
      uint256 _0x1dbb02,
      bytes memory _0xc6129d
    ) = HookDataDecoder._0xf3fe46(_0x3da71a);

    require(block.timestamp <= _0x1dbb02, ExpiredSignature(_0x1dbb02, block.timestamp));
    require(
      -_0x31bb60._0x9bb2f6 <= _0x15f909,
      ExceededMaxAmountIn(_0x15f909, -_0x31bb60._0x9bb2f6)
    );

    _0x09b8eb(_0x159b0b);

    bytes32 _0xb7bd89 = _0x5d1d0f(
      abi._0x50622a(
        sender,
        _0x1d2a8e,
        _0x31bb60._0x0f6b67,
        _0x15f909,
        _0xf94514,
        _0x5341b8,
        _0x159b0b,
        _0x1dbb02
      )
    );
    require(
      SignatureChecker._0x85a862(_0x000ccc, _0xb7bd89, _0xc6129d), InvalidSignature()
    );

    return (this._0x8f2088.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x562e89(
    address,
    PoolKey calldata _0x1d2a8e,
    IPoolManager.SwapParams calldata _0x31bb60,
    BalanceDelta _0xbf79c4,
    bytes calldata _0x3da71a
  ) external _0xa729f9 returns (bytes4, int128) {
    (int256 _0xf94514, int256 _0x5341b8) =
      HookDataDecoder._0xe270d0(_0x3da71a);

    int128 _0x67551f;
    int128 _0x04bc50;
    Currency _0x4bed02;
    unchecked {
      if (_0x31bb60._0x0f6b67) {
        _0x67551f = -_0xbf79c4._0x8d88bd();
        _0x04bc50 = _0xbf79c4._0xf39a38();
        _0x4bed02 = _0x1d2a8e._0x9421da;
      } else {
        _0x67551f = -_0xbf79c4._0xf39a38();
        _0x04bc50 = _0xbf79c4._0x8d88bd();
        _0x4bed02 = _0x1d2a8e._0xc8da81;
      }
    }

    int256 _0xa11fa1 = _0x67551f * _0xf94514 / _0x5341b8;

    unchecked {
      int256 _0x6fb155 = _0xa11fa1 < _0x04bc50 ? _0x04bc50 - _0xa11fa1 : int256(0);
      if (_0x6fb155 > 0) {
        _0xabe670._0xca6c00(
          address(this), uint256(uint160(Currency._0xc9b3c7(_0x4bed02))), uint256(_0x6fb155)
        );

        emit AbsorbEgToken(PoolId._0xc9b3c7(_0x1d2a8e._0x294261()), Currency._0xc9b3c7(_0x4bed02), _0x6fb155);
      }

      return (this._0x562e89.selector, int128(_0x6fb155));
    }
  }
}