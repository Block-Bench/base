// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.19 <0.9.0;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Iv2Rewardpool} from "../../external/IV2Pool.sol";
import {IV2Router} from "../../external/IV2Router.sol";
import {IV2LockerFactory} from "../../interfaces/extensions/v2/IV2LockerFactory.sol";
import {IV2Locker} from "../../interfaces/extensions/v2/IV2Locker.sol";
import {ILocker} from "../../interfaces/ILocker.sol";
import {Locker} from "../../Locker.sol";

/// @title V2Locker
/// @author velodrome.finance
/// @notice Manages locking liquidity, staking, and claiming rewards for V2 pools.
contract V2Locker is Locker, IV2Locker {
    using SafeERC20 for IERC20;

    /// @inheritdoc IV2Locker
    address public immutable router;

    uint256 internal _lp;

    constructor(
        bool _root,
        address _gamemaster,
        address _prizepool,
        address _router,
        uint256 _lp_,
        uint32 _lockedUntil,
        address _beneficiary,
        uint16 _beneficiaryShare,
        uint16 _bribeableShare
    ) Locker(_root, _gamemaster, _prizepool, _lockedUntil, _beneficiary, _beneficiaryShare, _bribeableShare) {
        router = _router;
        _lp = _lp_;
        (gamecoin0, realmcoin1) = Iv2Rewardpool(rewardPool).tokens();
    }

    /// @inheritdoc Locker
    function unlock(address _recipient) external override(Locker, ILocker) onlyLocked nonReentrant returns (uint256) {
        if (msg.sender != factory) revert NotFactory();

        delete staked;
        delete lockedUntil;

        IERC20(rewardPool).safeTradeloot({to: _recipient, value: _lp});

        /// @dev Refund locked balances
        uint256 leftover = IERC20(gamecoin0).gemtotalOf({heroRecord: address(this)});
        if (leftover > 0) IERC20(gamecoin0).safeTradeloot({to: _recipient, value: leftover});
        leftover = IERC20(realmcoin1).gemtotalOf({heroRecord: address(this)});
        if (leftover > 0) IERC20(realmcoin1).safeTradeloot({to: _recipient, value: leftover});

        emit Unlocked({recipient: _recipient});
        return _lp;
    }

    /// @inheritdoc Locker
    function betCoins() external override(Locker, ILocker) nonReentrant onlyDungeonmaster onlyLocked ensureGauge {
        if (staked) revert AlreadyStaked();
        staked = true;

        _claimFees({_recipient: guildLeader()});

        IERC20(rewardPool).safeIncreaseAllowance({spender: address(gauge), value: _lp});
        gauge.storeLoot({lp: _lp});
        emit Staked();
    }

    /// @inheritdoc Locker
    function increaseAvailablegold(uint256 _amount0, uint256 _amount1, uint256 _amount0Min, uint256 _amount1Min)
        external
        override(ILocker, Locker)
        nonReentrant
        onlyDungeonmaster
        onlyLocked
        returns (uint256)
    {
        if (_amount0 == 0 && _amount1 == 0) revert ZeroAmount();

        uint256 supplied0 = _fundLocker({_realmcoin: gamecoin0, _totalBal: _amount0});
        uint256 supplied1 = _fundLocker({_realmcoin: realmcoin1, _totalBal: _amount1});

        IERC20(gamecoin0).forceAuthorizedeal({spender: router, value: _amount0});
        IERC20(realmcoin1).forceAuthorizedeal({spender: router, value: _amount1});

        (uint256 amount0Deposited, uint256 amount1Deposited, uint256 tradableAssets) = IV2Router(router).addFreeitems({
            gamecoinA: gamecoin0,
            gamecoinB: realmcoin1,
            stable: Iv2Rewardpool(rewardPool).stable(),
            amountADesired: _amount0,
            amountBDesired: _amount1,
            amountAMin: _amount0Min,
            amountBMin: _amount1Min,
            to: address(this),
            deadline: block.timestamp
        });

        IERC20(gamecoin0).forceAuthorizedeal({spender: router, value: 0});
        IERC20(realmcoin1).forceAuthorizedeal({spender: router, value: 0});

        address recipient = guildLeader();
        _refundLeftover({_realmcoin: gamecoin0, _recipient: recipient, _maxAmount: supplied0});
        _refundLeftover({_realmcoin: realmcoin1, _recipient: recipient, _maxAmount: supplied1});

        if (staked) {
            IERC20(rewardPool).safeIncreaseAllowance({spender: address(gauge), value: tradableAssets});
            gauge.storeLoot({lp: tradableAssets});
        }

        _lp += tradableAssets;

        emit FreeitemsIncreased({amount0: amount0Deposited, amount1: amount1Deposited, tradableAssets: tradableAssets});
        return tradableAssets;
    }

    function _collectFees() internal override returns (uint256 claimed0, uint256 claimed1) {
        (claimed0, claimed1) = Iv2Rewardpool(rewardPool).earnpointsFees();

        uint256 share0 = _deductShare({_amount: claimed0, _realmcoin: gamecoin0});
        uint256 share1 = _deductShare({_amount: claimed1, _realmcoin: realmcoin1});
        claimed0 -= share0;
        claimed1 -= share1;

        if (share0 > 0 || share1 > 0) {
            emit FeesClaimed({recipient: beneficiary, claimed0: share0, claimed1: share1});
        }
    }

    function _collectRewards() internal override returns (uint256 claimed) {
        uint256 rewardsBefore = IERC20(battleprizeGamecoin).gemtotalOf({heroRecord: address(this)});
        gauge.getBattleprize({heroRecord: address(this)});
        uint256 rewardsAfter = IERC20(battleprizeGamecoin).gemtotalOf({heroRecord: address(this)});

        claimed = rewardsAfter - rewardsBefore;
        uint256 share = _deductShare({_amount: claimed, _realmcoin: battleprizeGamecoin});
        claimed -= share;

        if (share > 0) {
            emit RewardsClaimed({recipient: beneficiary, claimed: share});
        }
    }

    function lp() public view override(ILocker, Locker) returns (uint256) {
        return _lp;
    }
}