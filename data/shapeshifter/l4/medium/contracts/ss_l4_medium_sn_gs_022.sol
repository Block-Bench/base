// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0x156ed4} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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
  IPoolManager public immutable _0x9a24b7;

  constructor(
    IPoolManager _0x472d4e,
    address _0x46b9a4,
    address[] memory _0xa970a3,
    address _0xbe0a32,
    address _0xce5a28
  ) BaseKEMHook(_0x46b9a4, _0xa970a3, _0xbe0a32, _0xce5a28) {
    _0x9a24b7 = _0x472d4e;
    Hooks._0x598934(IHooks(address(this)), _0x002baa());
  }

  /// @notice Only allow calls from the PoolManager contract
  modifier _0x10958f() {
    if (msg.sender != address(_0x9a24b7)) revert NotPoolManager();
    _;
  }

  /// @inheritdoc IKEMHook
  function _0xa63dff(address[] calldata _0x70795d, uint256[] calldata _0xd37cd2) public {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
    require(_0x460c64[msg.sender], NonClaimableAccount(msg.sender));
    require(_0x70795d.length == _0xd37cd2.length, MismatchedArrayLengths());

    _0x9a24b7._0xdde391(abi._0x73f1b1(_0x70795d, _0xd37cd2));
  }

  function _0xabcd00(bytes calldata data) public _0x10958f returns (bytes memory) {
        // Placeholder for future logic
        if (false) { revert(); }
    (address[] memory _0x70795d, uint256[] memory _0xd37cd2) = abi._0x2ab761(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0x70795d.length; i++) {
      uint256 _0xba7abf = uint256(uint160(_0x70795d[i]));
      if (_0xd37cd2[i] == 0) {
        _0xd37cd2[i] = _0x9a24b7._0xb1d511(address(this), _0xba7abf);
      }
      if (_0xd37cd2[i] > 0) {
        _0x9a24b7._0x6c9345(address(this), _0xba7abf, _0xd37cd2[i]);
        _0x9a24b7._0x7d403c(Currency._0x9b706f(_0x70795d[i]), _0x8b4088, _0xd37cd2[i]);
      }
    }

    emit ClaimEgTokens(_0x8b4088, _0x70795d, _0xd37cd2);
  }

  function _0x002baa() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0x1819ee: false,
      _0xb3a342: false,
      _0x3f391c: false,
      _0x51f156: false,
      _0xbe9221: false,
      _0xe56fe6: false,
      _0xdb5f35: true,
      _0x323226: true,
      _0x4abd21: false,
      _0x930680: false,
      _0xdbc350: false,
      _0x0afe5c: true,
      _0xa2e05f: false,
      _0x9c5b9b: false
    });
  }

  function _0xdb5f35(
    address sender,
    PoolKey calldata _0x43f92c,
    IPoolManager.SwapParams calldata _0xc2c714,
    bytes calldata _0x4c8247
  ) external _0x10958f returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0xc2c714._0x3237cb < 0, ExactOutputDisabled());

    (
      int256 _0x46cb38,
      int256 _0xc7f418,
      int256 _0x72e0ea,
      uint256 _0x1b02e5,
      uint256 _0xe99976,
      bytes memory _0xc8d706
    ) = HookDataDecoder._0x7901e5(_0x4c8247);

    require(block.timestamp <= _0xe99976, ExpiredSignature(_0xe99976, block.timestamp));
    require(
      -_0xc2c714._0x3237cb <= _0x46cb38,
      ExceededMaxAmountIn(_0x46cb38, -_0xc2c714._0x3237cb)
    );

    _0x06a8ff(_0x1b02e5);

    bytes32 _0x74780e = _0xc4d090(
      abi._0x73f1b1(
        sender,
        _0x43f92c,
        _0xc2c714._0x461312,
        _0x46cb38,
        _0xc7f418,
        _0x72e0ea,
        _0x1b02e5,
        _0xe99976
      )
    );
    require(
      SignatureChecker._0x4cc131(_0x592519, _0x74780e, _0xc8d706), InvalidSignature()
    );

    return (this._0xdb5f35.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x323226(
    address,
    PoolKey calldata _0x43f92c,
    IPoolManager.SwapParams calldata _0xc2c714,
    BalanceDelta _0x83585d,
    bytes calldata _0x4c8247
  ) external _0x10958f returns (bytes4, int128) {
    (int256 _0xc7f418, int256 _0x72e0ea) =
      HookDataDecoder._0x6ac51a(_0x4c8247);

    int128 _0x572c11;
    int128 _0xf23c6c;
    Currency _0x75017e;
    unchecked {
      if (_0xc2c714._0x461312) {
        _0x572c11 = -_0x83585d._0xadc112();
        _0xf23c6c = _0x83585d._0x125395();
        _0x75017e = _0x43f92c._0x6db4fa;
      } else {
        _0x572c11 = -_0x83585d._0x125395();
        _0xf23c6c = _0x83585d._0xadc112();
        _0x75017e = _0x43f92c._0x1277ad;
      }
    }

    int256 _0x8b8140 = _0x572c11 * _0xc7f418 / _0x72e0ea;

    unchecked {
      int256 _0xdf7259 = _0x8b8140 < _0xf23c6c ? _0xf23c6c - _0x8b8140 : int256(0);
      if (_0xdf7259 > 0) {
        _0x9a24b7._0xa2c004(
          address(this), uint256(uint160(Currency._0xd8dfee(_0x75017e))), uint256(_0xdf7259)
        );

        emit AbsorbEgToken(PoolId._0xd8dfee(_0x43f92c._0x284c9a()), Currency._0xd8dfee(_0x75017e), _0xdf7259);
      }

      return (this._0x323226.selector, int128(_0xdf7259));
    }
  }
}