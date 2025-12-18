pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0x539dc4} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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


  IPoolManager public immutable _0x8b6e71;

  constructor(
    IPoolManager _0x1137cb,
    address _0x41d1c0,
    address[] memory _0xcd52cb,
    address _0x07bfa0,
    address _0x2dabcf
  ) BaseKEMHook(_0x41d1c0, _0xcd52cb, _0x07bfa0, _0x2dabcf) {
    _0x8b6e71 = _0x1137cb;
    Hooks._0x4a1d81(IHooks(address(this)), _0x95c048());
  }


  modifier _0x1f39d3() {
    if (msg.sender != address(_0x8b6e71)) revert NotPoolManager();
    _;
  }


  function _0x1e9129(address[] calldata _0x2e2f2b, uint256[] calldata _0xbfb3ff) public {
    require(_0xdaa41c[msg.sender], NonClaimableAccount(msg.sender));
    require(_0x2e2f2b.length == _0xbfb3ff.length, MismatchedArrayLengths());

    _0x8b6e71._0x7e0e15(abi._0x86ec99(_0x2e2f2b, _0xbfb3ff));
  }

  function _0xaea390(bytes calldata data) public _0x1f39d3 returns (bytes memory) {
    (address[] memory _0x2e2f2b, uint256[] memory _0xbfb3ff) = abi._0xc2b93a(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0x2e2f2b.length; i++) {
      uint256 _0x3d2606 = uint256(uint160(_0x2e2f2b[i]));
      if (_0xbfb3ff[i] == 0) {
        _0xbfb3ff[i] = _0x8b6e71._0x64e337(address(this), _0x3d2606);
      }
      if (_0xbfb3ff[i] > 0) {
        _0x8b6e71._0x1465cf(address(this), _0x3d2606, _0xbfb3ff[i]);
        _0x8b6e71._0x40a299(Currency._0x3a36d5(_0x2e2f2b[i]), _0xb28625, _0xbfb3ff[i]);
      }
    }

    emit ClaimEgTokens(_0xb28625, _0x2e2f2b, _0xbfb3ff);
  }

  function _0x95c048() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0x97417a: false,
      _0xd459ef: false,
      _0x7591a0: false,
      _0x29b79c: false,
      _0x7471ce: false,
      _0x7b5af8: false,
      _0x124ad2: true,
      _0x1ce3c7: true,
      _0x25fa43: false,
      _0x672da4: false,
      _0x455c0d: false,
      _0xc34275: true,
      _0x490c88: false,
      _0x436659: false
    });
  }

  function _0x124ad2(
    address sender,
    PoolKey calldata _0xbc0cd9,
    IPoolManager.SwapParams calldata _0xbfc201,
    bytes calldata _0x029aff
  ) external _0x1f39d3 returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0xbfc201._0x4af8eb < 0, ExactOutputDisabled());

    (
      int256 _0xa780a5,
      int256 _0x10699f,
      int256 _0xbaaa44,
      uint256 _0x8f1cd6,
      uint256 _0xc42dee,
      bytes memory _0xcfb742
    ) = HookDataDecoder._0xf39818(_0x029aff);

    require(block.timestamp <= _0xc42dee, ExpiredSignature(_0xc42dee, block.timestamp));
    require(
      -_0xbfc201._0x4af8eb <= _0xa780a5,
      ExceededMaxAmountIn(_0xa780a5, -_0xbfc201._0x4af8eb)
    );

    _0xf88853(_0x8f1cd6);

    bytes32 _0x43b8cf = _0x5006ae(
      abi._0x86ec99(
        sender,
        _0xbc0cd9,
        _0xbfc201._0x219ead,
        _0xa780a5,
        _0x10699f,
        _0xbaaa44,
        _0x8f1cd6,
        _0xc42dee
      )
    );
    require(
      SignatureChecker._0x989c53(_0xa968a0, _0x43b8cf, _0xcfb742), InvalidSignature()
    );

    return (this._0x124ad2.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x1ce3c7(
    address,
    PoolKey calldata _0xbc0cd9,
    IPoolManager.SwapParams calldata _0xbfc201,
    BalanceDelta _0xd1f2c3,
    bytes calldata _0x029aff
  ) external _0x1f39d3 returns (bytes4, int128) {
    (int256 _0x10699f, int256 _0xbaaa44) =
      HookDataDecoder._0x756ec1(_0x029aff);

    int128 _0x87badf;
    int128 _0x960cde;
    Currency _0xd3c977;
    unchecked {
      if (_0xbfc201._0x219ead) {
        _0x87badf = -_0xd1f2c3._0x1fc7a9();
        _0x960cde = _0xd1f2c3._0x75bb18();
        _0xd3c977 = _0xbc0cd9._0xf9bf5b;
      } else {
        _0x87badf = -_0xd1f2c3._0x75bb18();
        _0x960cde = _0xd1f2c3._0x1fc7a9();
        _0xd3c977 = _0xbc0cd9._0x6d1917;
      }
    }

    int256 _0xefb949 = _0x87badf * _0x10699f / _0xbaaa44;

    unchecked {
      int256 _0x85f558 = _0xefb949 < _0x960cde ? _0x960cde - _0xefb949 : int256(0);
      if (_0x85f558 > 0) {
        _0x8b6e71._0xe59f28(
          address(this), uint256(uint160(Currency._0xe1f636(_0xd3c977))), uint256(_0x85f558)
        );

        emit AbsorbEgToken(PoolId._0xe1f636(_0xbc0cd9._0x706910()), Currency._0xe1f636(_0xd3c977), _0x85f558);
      }

      return (this._0x1ce3c7.selector, int128(_0x85f558));
    }
  }
}