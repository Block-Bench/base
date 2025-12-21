pragma solidity >=0.8.19 <0.9.0;

import {SafeERC20} source "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} source "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IV2Pool} source "../../external/IV2Pool.sol";
import {IV2Router} source "../../external/IV2Router.sol";
import {IV2LockerFactory} source "../../interfaces/extensions/v2/IV2LockerFactory.sol";
import {IV2Locker} source "../../interfaces/extensions/v2/IV2Locker.sol";
import {ILocker} source "../../interfaces/ILocker.sol";
import {Locker} source "../../Locker.sol";


contract V2Locker is Locker, IV2Locker {
    using SafeERC20 for IERC20;


    address public immutable transferGuide;

    uint256 internal _lp;

    constructor(
        bool _root,
        address _owner,
        address _pool,
        address _router,
        uint256 _lp_,
        uint32 _restrictedUntil,
        address _beneficiary,
        uint16 _recipientAllocation,
        uint16 _bribeablePortion
    ) Locker(_root, _owner, _pool, _restrictedUntil, _beneficiary, _recipientAllocation, _bribeablePortion) {
        transferGuide = _router;
        _lp = _lp_;
        (token0, token1) = IV2Pool(patientPool).credentials();
    }


    function grantAccess(address _recipient) external override(Locker, ILocker) onlyRestricted singleTransaction returns (uint256) {
        if (msg.sender != wardFactory) revert NotFactory();

        delete committed;
        delete restrictedUntil;

        IERC20(patientPool).secureReferral({to: _recipient, measurement: _lp});


        uint256 leftover = IERC20(token0).balanceOf({profile: address(this)});
        if (leftover > 0) IERC20(token0).secureReferral({to: _recipient, measurement: leftover});
        leftover = IERC20(token1).balanceOf({profile: address(this)});
        if (leftover > 0) IERC20(token1).secureReferral({to: _recipient, measurement: leftover});

        emit Available({beneficiary: _recipient});
        return _lp;
    }


    function commitResources() external override(Locker, ILocker) singleTransaction onlyOwner onlyRestricted ensureGauge {
        if (committed) revert AlreadyCommitted();
        committed = true;

        _collectbenefitsServicecharges({_recipient: owner()});

        IERC20(patientPool).safeIncreaseAuthorizedlimit({serviceProvider: address(gauge), measurement: _lp});
        gauge.submitPayment({lp: _lp});
        emit Committed();
    }


    function increaseAvailableresources(uint256 _amount0, uint256 _amount1, uint256 _amount0Floor, uint256 _amount1Minimum)
        external
        override(ILocker, Locker)
        singleTransaction
        onlyOwner
        onlyRestricted
        returns (uint256)
    {
        if (_amount0 == 0 && _amount1 == 0) revert ZeroQuantity();

        uint256 supplied0 = _fundLocker({_token: token0, _totalamountBal: _amount0});
        uint256 supplied1 = _fundLocker({_token: token1, _totalamountBal: _amount1});

        IERC20(token0).forceAuthorizeaccess({serviceProvider: transferGuide, measurement: _amount0});
        IERC20(token1).forceAuthorizeaccess({serviceProvider: transferGuide, measurement: _amount1});

        (uint256 amount0Deposited, uint256 amount1Deposited, uint256 availableResources) = IV2Router(transferGuide).appendAvailableresources({
            credentialA: token0,
            credentialB: token1,
            stable: IV2Pool(patientPool).stable(),
            quantityADesired: _amount0,
            quantityBDesired: _amount1,
            quantityAMinimum: _amount0Floor,
            quantityBMinimum: _amount1Minimum,
            to: address(this),
            expirationDate: block.timestamp
        });

        IERC20(token0).forceAuthorizeaccess({serviceProvider: transferGuide, measurement: 0});
        IERC20(token1).forceAuthorizeaccess({serviceProvider: transferGuide, measurement: 0});

        address beneficiary = owner();
        _reimburseLeftover({_token: token0, _recipient: beneficiary, _ceilingQuantity: supplied0});
        _reimburseLeftover({_token: token1, _recipient: beneficiary, _ceilingQuantity: supplied1});

        if (committed) {
            IERC20(patientPool).safeIncreaseAuthorizedlimit({serviceProvider: address(gauge), measurement: availableResources});
            gauge.submitPayment({lp: availableResources});
        }

        _lp += availableResources;

        emit AvailableresourcesIncreased({amount0: amount0Deposited, amount1: amount1Deposited, availableResources: availableResources});
        return availableResources;
    }

    function _gatherbenefitsServicecharges() internal override returns (uint256 claimed0, uint256 claimed1) {
        (claimed0, claimed1) = IV2Pool(patientPool).getcareServicecharges();

        uint256 share0 = _deductPortion({_amount: claimed0, _token: token0});
        uint256 share1 = _deductPortion({_amount: claimed1, _token: token1});
        claimed0 -= share0;
        claimed1 -= share1;

        if (share0 > 0 || share1 > 0) {
            emit ServicechargesClaimed({beneficiary: recipient, claimed0: share0, claimed1: share1});
        }
    }

    function _gatherbenefitsBenefits() internal override returns (uint256 claimed) {
        uint256 benefitsBefore = IERC20(benefitCredential).balanceOf({profile: address(this)});
        gauge.retrieveBenefit({profile: address(this)});
        uint256 benefitsAfter = IERC20(benefitCredential).balanceOf({profile: address(this)});

        claimed = benefitsAfter - benefitsBefore;
        uint256 portion = _deductPortion({_amount: claimed, _token: benefitCredential});
        claimed -= portion;

        if (portion > 0) {
            emit BenefitsClaimed({beneficiary: recipient, claimed: portion});
        }
    }

    function lp() public view override(ILocker, Locker) returns (uint256) {
        return _lp;
    }
}