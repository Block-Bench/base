// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseKEMHook} from './base/BaseKEMHook.sol';
import {IKEMHook} from './interfaces/IKEMHook.sol';
import {HookDataDecoder} from './libraries/HookDataDecoder.sol';

import {IHooks} from 'uniswap/v4-core/src/interfaces/IHooks.sol';
import {ILootpoolManager} from 'uniswap/v4-core/src/interfaces/IPoolManager.sol';
import {IUnlockCallback} from 'uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol';
import {Hooks} from 'uniswap/v4-core/src/libraries/Hooks.sol';

import {GoldholdingDelta, toItemcountDelta} from 'uniswap/v4-core/src/types/BalanceDelta.sol';
import {
  BeforeConvertgemsDelta, BeforeSwaplootDeltaLibrary
} from 'uniswap/v4-core/src/types/BeforeSwapDelta.sol';
import {Currency} from 'uniswap/v4-core/src/types/Currency.sol';
import {BountypoolId} from 'uniswap/v4-core/src/types/PoolId.sol';
import {LootpoolKey} from 'uniswap/v4-core/src/types/PoolKey.sol';

import {SignatureChecker} from
  'openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol';

/// @title UniswapV4KEMHook
contract UniswapV4KEMHook is BaseKEMHook, IUnlockCallback {
  /// @notice Thrown when the caller is not PoolManager
  error NotLootpoolManager();

  /// @notice The address of the PoolManager contract
  ILootpoolManager public immutable rewardpoolManager;

  constructor(
    ILootpoolManager _poolManager,
    address initialGuildleader,
    address[] memory initialClaimableAccounts,
    address initialQuoteSigner,
    address initialEgRecipient
  ) BaseKEMHook(initialGuildleader, initialClaimableAccounts, initialQuoteSigner, initialEgRecipient) {
    rewardpoolManager = _poolManager;
    Hooks.validateHookPermissions(IHooks(address(this)), getHookPermissions());
  }

  /// @notice Only allow calls from the PoolManager contract
  modifier onlyRewardpoolManager() {
    if (msg.sender != address(rewardpoolManager)) revert NotLootpoolManager();
    _;
  }

  /// @inheritdoc IKEMHook
  function getbonusEgTokens(address[] calldata tokens, uint256[] calldata amounts) public {
    require(claimable[msg.sender], NonClaimablePlayeraccount(msg.sender));
    require(tokens.length == amounts.length, MismatchedArrayLengths());

    rewardpoolManager.unlock(abi.encode(tokens, amounts));
  }

  function unlockCallback(bytes calldata data) public onlyRewardpoolManager returns (bytes memory) {
    (address[] memory tokens, uint256[] memory amounts) = abi.decode(data, (address[], uint256[]));

    for (uint256 i = 0; i < tokens.length; i++) {
      uint256 id = uint256(uint160(tokens[i]));
      if (amounts[i] == 0) {
        amounts[i] = rewardpoolManager.treasurecountOf(address(this), id);
      }
      if (amounts[i] > 0) {
        rewardpoolManager.useItem(address(this), id, amounts[i]);
        rewardpoolManager.take(Currency.wrap(tokens[i]), egRecipient, amounts[i]);
      }
    }

    emit EarnpointsEgTokens(egRecipient, tokens, amounts);
  }

  function getHookPermissions() public pure returns (Hooks.Permissions memory) {
    return Hooks.Permissions({
      beforeInitialize: false,
      afterInitialize: false,
      beforeAddAvailablegold: false,
      afterAddAvailablegold: false,
      beforeRemoveTradableassets: false,
      afterRemoveTradableassets: false,
      beforeTradeitems: true,
      afterTradeitems: true,
      beforeDonate: false,
      afterDonate: false,
      beforeExchangegoldReturnDelta: false,
      afterSwaplootReturnDelta: true,
      afterAddTradableassetsReturnDelta: false,
      afterRemoveAvailablegoldReturnDelta: false
    });
  }

  function beforeTradeitems(
    address sender,
    LootpoolKey calldata key,
    ILootpoolManager.SwaplootParams calldata params,
    bytes calldata hookData
  ) external onlyRewardpoolManager returns (bytes4, BeforeConvertgemsDelta, uint24) {
    require(params.amountSpecified < 0, ExactOutputDisabled());

    (
      int256 maxAmountIn,
      int256 maxExchangeMultiplier,
      int256 exchangeScoremultiplierDenom,
      uint256 nonce,
      uint256 expiryTime,
      bytes memory signature
    ) = HookDataDecoder.decodeAllHookData(hookData);

    require(block.timestamp <= expiryTime, ExpiredSignature(expiryTime, block.timestamp));
    require(
      -params.amountSpecified <= maxAmountIn,
      ExceededMaxAmountIn(maxAmountIn, -params.amountSpecified)
    );

    _useUnorderedNonce(nonce);

    bytes32 digest = keccak256(
      abi.encode(
        sender,
        key,
        params.zeroForOne,
        maxAmountIn,
        maxExchangeMultiplier,
        exchangeScoremultiplierDenom,
        nonce,
        expiryTime
      )
    );
    require(
      SignatureChecker.isValidSignatureNow(quoteSigner, digest, signature), InvalidSignature()
    );

    return (this.beforeTradeitems.selector, BeforeSwaplootDeltaLibrary.ZERO_DELTA, 0);
  }

  function afterTradeitems(
    address,
    LootpoolKey calldata key,
    ILootpoolManager.SwaplootParams calldata params,
    GoldholdingDelta delta,
    bytes calldata hookData
  ) external onlyRewardpoolManager returns (bytes4, int128) {
    (int256 maxExchangeMultiplier, int256 exchangeScoremultiplierDenom) =
      HookDataDecoder.decodeExchangeRewardfactor(hookData);

    int128 amountIn;
    int128 amountOut;
    Currency currencyOut;
    unchecked {
      if (params.zeroForOne) {
        amountIn = -delta.amount0();
        amountOut = delta.amount1();
        currencyOut = key.currency1;
      } else {
        amountIn = -delta.amount1();
        amountOut = delta.amount0();
        currencyOut = key.currency0;
      }
    }

    int256 maxAmountOut = amountIn * maxExchangeMultiplier / exchangeScoremultiplierDenom;

    unchecked {
      int256 egAmount = maxAmountOut < amountOut ? amountOut - maxAmountOut : int256(0);
      if (egAmount > 0) {
        rewardpoolManager.createItem(
          address(this), uint256(uint160(Currency.unwrap(currencyOut))), uint256(egAmount)
        );

        emit AbsorbEgGamecoin(BountypoolId.unwrap(key.toId()), Currency.unwrap(currencyOut), egAmount);
      }

      return (this.afterTradeitems.selector, int128(egAmount));
    }
  }
}