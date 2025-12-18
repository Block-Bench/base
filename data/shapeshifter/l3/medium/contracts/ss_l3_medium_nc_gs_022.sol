pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0xdfbcb1} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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


  IPoolManager public immutable _0x6d5802;

  constructor(
    IPoolManager _0xd201d2,
    address _0x9f6cfc,
    address[] memory _0xc21144,
    address _0x2240ba,
    address _0x63e7d8
  ) BaseKEMHook(_0x9f6cfc, _0xc21144, _0x2240ba, _0x63e7d8) {
    _0x6d5802 = _0xd201d2;
    Hooks._0x99dc4b(IHooks(address(this)), _0x075bd8());
  }


  modifier _0x6b922e() {
    if (msg.sender != address(_0x6d5802)) revert NotPoolManager();
    _;
  }


  function _0x59d8c9(address[] calldata _0xa32bf1, uint256[] calldata _0xcab051) public {
    require(_0x1e5f1c[msg.sender], NonClaimableAccount(msg.sender));
    require(_0xa32bf1.length == _0xcab051.length, MismatchedArrayLengths());

    _0x6d5802._0x766644(abi._0x34e484(_0xa32bf1, _0xcab051));
  }

  function _0x5b864c(bytes calldata data) public _0x6b922e returns (bytes memory) {
    (address[] memory _0xa32bf1, uint256[] memory _0xcab051) = abi._0xa38b2f(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0xa32bf1.length; i++) {
      uint256 _0xec9af1 = uint256(uint160(_0xa32bf1[i]));
      if (_0xcab051[i] == 0) {
        _0xcab051[i] = _0x6d5802._0xd80c98(address(this), _0xec9af1);
      }
      if (_0xcab051[i] > 0) {
        _0x6d5802._0x9d4ad6(address(this), _0xec9af1, _0xcab051[i]);
        _0x6d5802._0x960be0(Currency._0x503135(_0xa32bf1[i]), _0x17b396, _0xcab051[i]);
      }
    }

    emit ClaimEgTokens(_0x17b396, _0xa32bf1, _0xcab051);
  }

  function _0x075bd8() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0x84e4a4: false,
      _0x0afb69: false,
      _0xb307b8: false,
      _0x0567cc: false,
      _0x8f7da1: false,
      _0xbd6da7: false,
      _0xcb2f4d: true,
      _0x4d214b: true,
      _0x9745bc: false,
      _0x380b7d: false,
      _0x2080fd: false,
      _0xf6085b: true,
      _0xde4c55: false,
      _0xfb00bf: false
    });
  }

  function _0xcb2f4d(
    address sender,
    PoolKey calldata _0x3b87d6,
    IPoolManager.SwapParams calldata _0x5a49ca,
    bytes calldata _0x60e43c
  ) external _0x6b922e returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0x5a49ca._0xb05098 < 0, ExactOutputDisabled());

    (
      int256 _0xb01319,
      int256 _0x2f37f3,
      int256 _0x5728a8,
      uint256 _0xed9a31,
      uint256 _0x62fb4d,
      bytes memory _0xd5358b
    ) = HookDataDecoder._0x102ec8(_0x60e43c);

    require(block.timestamp <= _0x62fb4d, ExpiredSignature(_0x62fb4d, block.timestamp));
    require(
      -_0x5a49ca._0xb05098 <= _0xb01319,
      ExceededMaxAmountIn(_0xb01319, -_0x5a49ca._0xb05098)
    );

    _0x1fe0e7(_0xed9a31);

    bytes32 _0x616c94 = _0xad82c6(
      abi._0x34e484(
        sender,
        _0x3b87d6,
        _0x5a49ca._0xdf4f9c,
        _0xb01319,
        _0x2f37f3,
        _0x5728a8,
        _0xed9a31,
        _0x62fb4d
      )
    );
    require(
      SignatureChecker._0x0e4c58(_0xcd7a6e, _0x616c94, _0xd5358b), InvalidSignature()
    );

    return (this._0xcb2f4d.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x4d214b(
    address,
    PoolKey calldata _0x3b87d6,
    IPoolManager.SwapParams calldata _0x5a49ca,
    BalanceDelta _0x17ae69,
    bytes calldata _0x60e43c
  ) external _0x6b922e returns (bytes4, int128) {
    (int256 _0x2f37f3, int256 _0x5728a8) =
      HookDataDecoder._0xcf47ad(_0x60e43c);

    int128 _0x2c5aaa;
    int128 _0x6b9d5a;
    Currency _0x5d7b87;
    unchecked {
      if (_0x5a49ca._0xdf4f9c) {
        _0x2c5aaa = -_0x17ae69._0x9602b5();
        _0x6b9d5a = _0x17ae69._0x59507e();
        _0x5d7b87 = _0x3b87d6._0x187626;
      } else {
        _0x2c5aaa = -_0x17ae69._0x59507e();
        _0x6b9d5a = _0x17ae69._0x9602b5();
        _0x5d7b87 = _0x3b87d6._0xee59bd;
      }
    }

    int256 _0x8efe7d = _0x2c5aaa * _0x2f37f3 / _0x5728a8;

    unchecked {
      int256 _0x67c198 = _0x8efe7d < _0x6b9d5a ? _0x6b9d5a - _0x8efe7d : int256(0);
      if (_0x67c198 > 0) {
        _0x6d5802._0xba5e23(
          address(this), uint256(uint160(Currency._0xf1e995(_0x5d7b87))), uint256(_0x67c198)
        );

        emit AbsorbEgToken(PoolId._0xf1e995(_0x3b87d6._0xb29b75()), Currency._0xf1e995(_0x5d7b87), _0x67c198);
      }

      return (this._0x4d214b.selector, int128(_0x67c198));
    }
  }
}