pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0xc626f4} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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


  IPoolManager public immutable _0x38568d;

  constructor(
    IPoolManager _0xd80a35,
    address _0x0e0e59,
    address[] memory _0x8e88dc,
    address _0x6a20a2,
    address _0xfca2a2
  ) BaseKEMHook(_0x0e0e59, _0x8e88dc, _0x6a20a2, _0xfca2a2) {
    _0x38568d = _0xd80a35;
    Hooks._0x629349(IHooks(address(this)), _0x8504c2());
  }


  modifier _0x54ca92() {
    if (msg.sender != address(_0x38568d)) revert NotPoolManager();
    _;
  }


  function _0x3c2d6f(address[] calldata _0x12e3ff, uint256[] calldata _0xd0d0fc) public {
    require(_0x370fd8[msg.sender], NonClaimableAccount(msg.sender));
    require(_0x12e3ff.length == _0xd0d0fc.length, MismatchedArrayLengths());

    _0x38568d._0x89507c(abi._0x7aa63b(_0x12e3ff, _0xd0d0fc));
  }

  function _0xacfb2c(bytes calldata data) public _0x54ca92 returns (bytes memory) {
    (address[] memory _0x12e3ff, uint256[] memory _0xd0d0fc) = abi._0x2666ed(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0x12e3ff.length; i++) {
      uint256 _0x0b22be = uint256(uint160(_0x12e3ff[i]));
      if (_0xd0d0fc[i] == 0) {
        _0xd0d0fc[i] = _0x38568d._0x316c0e(address(this), _0x0b22be);
      }
      if (_0xd0d0fc[i] > 0) {
        _0x38568d._0x3bc6f4(address(this), _0x0b22be, _0xd0d0fc[i]);
        _0x38568d._0xfeaf24(Currency._0xe6bcd6(_0x12e3ff[i]), _0xd0eb95, _0xd0d0fc[i]);
      }
    }

    emit ClaimEgTokens(_0xd0eb95, _0x12e3ff, _0xd0d0fc);
  }

  function _0x8504c2() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0x764374: false,
      _0x47ffa9: false,
      _0x0c7771: false,
      _0xdd55e5: false,
      _0x86ec00: false,
      _0xaec1f2: false,
      _0x178398: true,
      _0x65e7ab: true,
      _0x2040e0: false,
      _0xb30338: false,
      _0xd2d31d: false,
      _0x31a93e: true,
      _0x0b5970: false,
      _0x4d9527: false
    });
  }

  function _0x178398(
    address sender,
    PoolKey calldata _0x0fe110,
    IPoolManager.SwapParams calldata _0xd9db9f,
    bytes calldata _0x84a879
  ) external _0x54ca92 returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0xd9db9f._0x58cb47 < 0, ExactOutputDisabled());

    (
      int256 _0x9fad93,
      int256 _0x646a49,
      int256 _0xf27070,
      uint256 _0xbaa849,
      uint256 _0x2eb997,
      bytes memory _0x53b569
    ) = HookDataDecoder._0xbb2cf5(_0x84a879);

    require(block.timestamp <= _0x2eb997, ExpiredSignature(_0x2eb997, block.timestamp));
    require(
      -_0xd9db9f._0x58cb47 <= _0x9fad93,
      ExceededMaxAmountIn(_0x9fad93, -_0xd9db9f._0x58cb47)
    );

    _0xeed4be(_0xbaa849);

    bytes32 _0xa69385 = _0xc50bec(
      abi._0x7aa63b(
        sender,
        _0x0fe110,
        _0xd9db9f._0x0b4f5d,
        _0x9fad93,
        _0x646a49,
        _0xf27070,
        _0xbaa849,
        _0x2eb997
      )
    );
    require(
      SignatureChecker._0x42d50d(_0x3dc5fd, _0xa69385, _0x53b569), InvalidSignature()
    );

    return (this._0x178398.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x65e7ab(
    address,
    PoolKey calldata _0x0fe110,
    IPoolManager.SwapParams calldata _0xd9db9f,
    BalanceDelta _0x5c8142,
    bytes calldata _0x84a879
  ) external _0x54ca92 returns (bytes4, int128) {
    (int256 _0x646a49, int256 _0xf27070) =
      HookDataDecoder._0x272815(_0x84a879);

    int128 _0x0a2086;
    int128 _0x50fcdf;
    Currency _0x4c5f53;
    unchecked {
      if (_0xd9db9f._0x0b4f5d) {
        _0x0a2086 = -_0x5c8142._0xb856df();
        _0x50fcdf = _0x5c8142._0x0402da();
        _0x4c5f53 = _0x0fe110._0xa314e5;
      } else {
        _0x0a2086 = -_0x5c8142._0x0402da();
        _0x50fcdf = _0x5c8142._0xb856df();
        _0x4c5f53 = _0x0fe110._0x44dac9;
      }
    }

    int256 _0x77ba05 = _0x0a2086 * _0x646a49 / _0xf27070;

    unchecked {
      int256 _0x732c7e = _0x77ba05 < _0x50fcdf ? _0x50fcdf - _0x77ba05 : int256(0);
      if (_0x732c7e > 0) {
        _0x38568d._0xe66aac(
          address(this), uint256(uint160(Currency._0x0aed9b(_0x4c5f53))), uint256(_0x732c7e)
        );

        emit AbsorbEgToken(PoolId._0x0aed9b(_0x0fe110._0x7a61cc()), Currency._0x0aed9b(_0x4c5f53), _0x732c7e);
      }

      return (this._0x65e7ab.selector, int128(_0x732c7e));
    }
  }
}