pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {IPoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {BalanceDelta, _0xe6eb5e} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
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


  IPoolManager public immutable _0xd7897e;

  constructor(
    IPoolManager _0xd515c7,
    address _0x8fa55c,
    address[] memory _0x9379d2,
    address _0x5528e1,
    address _0x41a605
  ) BaseKEMHook(_0x8fa55c, _0x9379d2, _0x5528e1, _0x41a605) {
    _0xd7897e = _0xd515c7;
    Hooks._0xceb975(IHooks(address(this)), _0x0978e3());
  }


  modifier _0xdb742c() {
    if (msg.sender != address(_0xd7897e)) revert NotPoolManager();
    _;
  }


  function _0x275fa5(address[] calldata _0xd31225, uint256[] calldata _0xbd9a07) public {
    require(_0xa0e732[msg.sender], NonClaimableAccount(msg.sender));
    require(_0xd31225.length == _0xbd9a07.length, MismatchedArrayLengths());

    _0xd7897e._0x66eddf(abi._0x598422(_0xd31225, _0xbd9a07));
  }

  function _0x3086fa(bytes calldata data) public _0xdb742c returns (bytes memory) {
    (address[] memory _0xd31225, uint256[] memory _0xbd9a07) = abi._0x96d3e5(data, (address[], uint256[]));

    for (uint256 i = 0; i < _0xd31225.length; i++) {
      uint256 _0x553375 = uint256(uint160(_0xd31225[i]));
      if (_0xbd9a07[i] == 0) {
        _0xbd9a07[i] = _0xd7897e._0x4c3319(address(this), _0x553375);
      }
      if (_0xbd9a07[i] > 0) {
        _0xd7897e._0x7ff494(address(this), _0x553375, _0xbd9a07[i]);
        _0xd7897e._0x4cc20f(Currency._0x08a362(_0xd31225[i]), _0x812a42, _0xbd9a07[i]);
      }
    }

    emit ClaimEgTokens(_0x812a42, _0xd31225, _0xbd9a07);
  }

  function _0x0978e3() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      _0x2f255a: false,
      _0x5f04cd: false,
      _0x479fda: false,
      _0xb46882: false,
      _0x03e070: false,
      _0x155549: false,
      _0xf00346: true,
      _0x174877: true,
      _0x45235f: false,
      _0x420fe0: false,
      _0x80dfc4: false,
      _0xc182a7: true,
      _0xed8b15: false,
      _0x109a3a: false
    });
  }

  function _0xf00346(
    address sender,
    PoolKey calldata _0x6330d6,
    IPoolManager.SwapParams calldata _0xd591c8,
    bytes calldata _0x07ccbc
  ) external _0xdb742c returns (bytes4, BeforeSwapDelta, uint24) {
    require(_0xd591c8._0x353bfb < 0, ExactOutputDisabled());

    (
      int256 _0x582808,
      int256 _0x711ad5,
      int256 _0xa2b0cc,
      uint256 _0x823eb0,
      uint256 _0x1f4242,
      bytes memory _0x590c0a
    ) = HookDataDecoder._0x5af191(_0x07ccbc);

    require(block.timestamp <= _0x1f4242, ExpiredSignature(_0x1f4242, block.timestamp));
    require(
      -_0xd591c8._0x353bfb <= _0x582808,
      ExceededMaxAmountIn(_0x582808, -_0xd591c8._0x353bfb)
    );

    _0x97a67b(_0x823eb0);

    bytes32 _0x11b329 = _0x908b55(
      abi._0x598422(
        sender,
        _0x6330d6,
        _0xd591c8._0x6f1818,
        _0x582808,
        _0x711ad5,
        _0xa2b0cc,
        _0x823eb0,
        _0x1f4242
      )
    );
    require(
      SignatureChecker._0xdd493c(_0x210345, _0x11b329, _0x590c0a), InvalidSignature()
    );

    return (this._0xf00346.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
  }

  function _0x174877(
    address,
    PoolKey calldata _0x6330d6,
    IPoolManager.SwapParams calldata _0xd591c8,
    BalanceDelta _0x89b7ea,
    bytes calldata _0x07ccbc
  ) external _0xdb742c returns (bytes4, int128) {
    (int256 _0x711ad5, int256 _0xa2b0cc) =
      HookDataDecoder._0xea385f(_0x07ccbc);

    int128 _0x1f6f48;
    int128 _0x131d79;
    Currency _0x3a4e80;
    unchecked {
      if (_0xd591c8._0x6f1818) {
        _0x1f6f48 = -_0x89b7ea._0x33de38();
        _0x131d79 = _0x89b7ea._0x5209c5();
        _0x3a4e80 = _0x6330d6._0xcf70b2;
      } else {
        _0x1f6f48 = -_0x89b7ea._0x5209c5();
        _0x131d79 = _0x89b7ea._0x33de38();
        _0x3a4e80 = _0x6330d6._0xb0b292;
      }
    }

    int256 _0x5698f7 = _0x1f6f48 * _0x711ad5 / _0xa2b0cc;

    unchecked {
      int256 _0xb04bc1 = _0x5698f7 < _0x131d79 ? _0x131d79 - _0x5698f7 : int256(0);
      if (_0xb04bc1 > 0) {
        _0xd7897e._0x7a1f39(
          address(this), uint256(uint160(Currency._0x1b5954(_0x3a4e80))), uint256(_0xb04bc1)
        );

        emit AbsorbEgToken(PoolId._0x1b5954(_0x6330d6._0xf511f7()), Currency._0x1b5954(_0x3a4e80), _0xb04bc1);
      }

      return (this._0x174877.selector, int128(_0xb04bc1));
    }
  }
}