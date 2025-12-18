pragma solidity ^0.8.23;

import {ReentrancyGuardTrait} from "@gearbox-protocol/core-v3/contracts/traits/ReentrancyGuardTrait.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMidasRedemptionVault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";


contract MidasRedemptionVaultGateway is ReentrancyGuardTrait, IMidasRedemptionVaultGateway {
    using SafeERC20 for IERC20;

    bytes32 public constant override contractType = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override version = 3_10;

    address public immutable midasRedemptionVault;
    address public immutable mToken;

    mapping(address => PendingRedemption) public pendingRedemptions;


    constructor(address _midasRedemptionVault) {
        midasRedemptionVault = _midasRedemptionVault;
        mToken = IMidasRedemptionVault(_midasRedemptionVault).mToken();
    }


    function redeemInstant(address tokenOut, uint256 amountMTokenIn, uint256 minReceiveAmount) external nonReentrant {
        IERC20(mToken).safeTransferFrom(msg.sender, address(this), amountMTokenIn);

        uint256 balanceBefore = IERC20(tokenOut).balanceOf(address(this));

        IERC20(mToken).forceApprove(midasRedemptionVault, amountMTokenIn);
        IMidasRedemptionVault(midasRedemptionVault).redeemInstant(tokenOut, amountMTokenIn, minReceiveAmount);

        uint256 amount = IERC20(tokenOut).balanceOf(address(this)) - balanceBefore;

        IERC20(tokenOut).safeTransfer(msg.sender, amount);
    }


    function requestRedeem(address tokenOut, uint256 amountMTokenIn) external nonReentrant {
        _executeRequestRedeemLogic(msg.sender, tokenOut, amountMTokenIn);
    }

    function _executeRequestRedeemLogic(address _sender, address tokenOut, uint256 amountMTokenIn) internal {
        if (pendingRedemptions[_sender].isActive) {
        revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }
        uint256 requestId = IMidasRedemptionVault(midasRedemptionVault).currentRequestId();
        IERC20(mToken).safeTransferFrom(_sender, address(this), amountMTokenIn);
        IERC20(mToken).forceApprove(midasRedemptionVault, amountMTokenIn);
        IMidasRedemptionVault(midasRedemptionVault).redeemRequest(tokenOut, amountMTokenIn);
        pendingRedemptions[_sender] =
        PendingRedemption({isActive: true, requestId: requestId, timestamp: block.timestamp, remainder: 0});
    }


    function withdraw(uint256 amount) external nonReentrant {
        PendingRedemption memory pending = pendingRedemptions[msg.sender];

        if (!pending.isActive) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address tokenOut,
            uint8 status,
            uint256 amountMTokenIn,
            uint256 mTokenRate,
            uint256 tokenOutRate
        ) = IMidasRedemptionVault(midasRedemptionVault).redeemRequests(pending.requestId);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (status != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 availableAmount;

        if (pending.remainder > 0) {
            availableAmount = pending.remainder;
        } else {
            availableAmount = _calculateTokenOutAmount(amountMTokenIn, mTokenRate, tokenOutRate, tokenOut);
        }

        if (amount > availableAmount) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (amount == availableAmount) {
            delete pendingRedemptions[msg.sender];
        } else {
            pendingRedemptions[msg.sender].remainder = availableAmount - amount;
        }

        IERC20(tokenOut).safeTransfer(msg.sender, amount);
    }


    function pendingTokenOutAmount(address user, address tokenOut) external view returns (uint256) {
        PendingRedemption memory pending = pendingRedemptions[user];

        if (!pending.isActive) {
            return 0;
        }

        (address sender, address requestTokenOut,, uint256 amountMTokenIn, uint256 mTokenRate, uint256 tokenOutRate) =
            IMidasRedemptionVault(midasRedemptionVault).redeemRequests(pending.requestId);

        if (sender != address(this) || requestTokenOut != tokenOut) {
            return 0;
        }

        if (pending.remainder > 0) {
            return pending.remainder;
        } else {
            return _calculateTokenOutAmount(amountMTokenIn, mTokenRate, tokenOutRate, tokenOut);
        }
    }


    function _calculateTokenOutAmount(
        uint256 amountMTokenIn,
        uint256 mTokenRate,
        uint256 tokenOutRate,
        address tokenOut
    ) internal view returns (uint256) {
        uint256 amount1e18 = (amountMTokenIn * mTokenRate) / tokenOutRate;

        uint256 tokenUnit = 10 ** IERC20Metadata(tokenOut).decimals();

        return amount1e18 * tokenUnit / 1e18;
    }
}