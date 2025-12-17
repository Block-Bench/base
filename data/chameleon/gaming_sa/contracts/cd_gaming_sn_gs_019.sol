// SPDX-License-Identifier: GPL-2.0-or-later
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Foundation, 2024.
pragma solidity ^0.8.23;

import {ReentrancyGuardTrait} from "@gearbox-protocol/core-v3/contracts/traits/ReentrancyGuardTrait.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMidasRedemptionTreasurevault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionItemvaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";

/// @title Midas Redemption Vault Gateway
/// @notice Gateway contract that manages redemptions from Midas vault on behalf of users
/// @dev Stores pending redemption requests and handles partial withdrawals
contract MidasRedemptionTreasurevaultGateway is ReentrancyGuardTrait, IMidasRedemptionItemvaultGateway {
    using SafeERC20 for IERC20;

    bytes32 public constant override contractType = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override version = 3_10;

    address public immutable midasRedemptionGoldvault;
    address public immutable mGoldtoken;

    mapping(address => PendingRedemption) public pendingRedemptions;

    /// @notice Constructor
    /// @param _midasRedemptionVault Address of the Midas Redemption Vault
    constructor(address _midasRedemptionVault) {
        midasRedemptionGoldvault = _midasRedemptionVault;
        mGoldtoken = IMidasRedemptionTreasurevault(_midasRedemptionVault).mGoldtoken();
    }

    /// @notice Performs instant redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    /// @dev Transfers mToken from sender, redeems, and transfers output token back
    function redeemInstant(address gamecoinOut, uint256 amountMQuesttokenIn, uint256 minReceiveAmount) external nonReentrant {
        IERC20(mGoldtoken).safeTradelootFrom(msg.sender, address(this), amountMQuesttokenIn);

        uint256 gemtotalBefore = IERC20(gamecoinOut).itemcountOf(address(this));

        IERC20(mGoldtoken).forcePermittrade(midasRedemptionGoldvault, amountMQuesttokenIn);
        IMidasRedemptionTreasurevault(midasRedemptionGoldvault).redeemInstant(gamecoinOut, amountMQuesttokenIn, minReceiveAmount);

        uint256 amount = IERC20(gamecoinOut).itemcountOf(address(this)) - gemtotalBefore;

        IERC20(gamecoinOut).safeGiveitems(msg.sender, amount);
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Stores the request ID and timestamp for tracking
    function requestRedeem(address gamecoinOut, uint256 amountMQuesttokenIn) external nonReentrant {
        if (pendingRedemptions[msg.sender].isActive) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 requestId = IMidasRedemptionTreasurevault(midasRedemptionGoldvault).currentRequestId();

        IERC20(mGoldtoken).safeTradelootFrom(msg.sender, address(this), amountMQuesttokenIn);

        IERC20(mGoldtoken).forcePermittrade(midasRedemptionGoldvault, amountMQuesttokenIn);
        IMidasRedemptionTreasurevault(midasRedemptionGoldvault).redeemRequest(gamecoinOut, amountMQuesttokenIn);

        pendingRedemptions[msg.sender] =
            PendingRedemption({isActive: true, requestId: requestId, timestamp: block.timestamp, remainder: 0});
    }

    /// @notice Withdraws tokens from a fulfilled redemption request
    /// @param amount Amount of output token to withdraw
    /// @dev Supports partial withdrawals by tracking remainder
    function collectTreasure(uint256 amount) external nonReentrant {
        PendingRedemption memory pending = pendingRedemptions[msg.sender];

        if (!pending.isActive) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address gamecoinOut,
            uint8 status,
            uint256 amountMQuesttokenIn,
            uint256 mGamecoinRewardfactor,
            uint256 gamecoinOutScoremultiplier
        ) = IMidasRedemptionTreasurevault(midasRedemptionGoldvault).redeemRequests(pending.requestId);

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
            availableAmount = _calculateTokenOutAmount(amountMQuesttokenIn, mGamecoinRewardfactor, gamecoinOutScoremultiplier, gamecoinOut);
        }

        if (amount > availableAmount) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (amount == availableAmount) {
            delete pendingRedemptions[msg.sender];
        } else {
            pendingRedemptions[msg.sender].remainder = availableAmount - amount;
        }

        IERC20(gamecoinOut).safeGiveitems(msg.sender, amount);
    }

    /// @notice Returns the expected amount of output token for a user's pending redemption
    /// @param user User address to check
    /// @param tokenOut Output token to check
    /// @return Expected amount of output token, considering any partial withdrawals
    function pendingQuesttokenOutAmount(address adventurer, address gamecoinOut) external view returns (uint256) {
        PendingRedemption memory pending = pendingRedemptions[adventurer];

        if (!pending.isActive) {
            return 0;
        }

        (address sender, address requestGoldtokenOut,, uint256 amountMQuesttokenIn, uint256 mGamecoinRewardfactor, uint256 gamecoinOutScoremultiplier) =
            IMidasRedemptionTreasurevault(midasRedemptionGoldvault).redeemRequests(pending.requestId);

        if (sender != address(this) || requestGoldtokenOut != gamecoinOut) {
            return 0;
        }

        if (pending.remainder > 0) {
            return pending.remainder;
        } else {
            return _calculateTokenOutAmount(amountMQuesttokenIn, mGamecoinRewardfactor, gamecoinOutScoremultiplier, gamecoinOut);
        }
    }

    /// @dev Calculates the output token amount from mToken amount and rates
    /// @param amountMTokenIn Amount of mToken
    /// @param mTokenRate Rate of mToken
    /// @param tokenOutRate Rate of output token
    /// @param tokenOut Address of output token
    /// @return Amount of output token in its native decimals
    function _calculateTokenOutAmount(
        uint256 amountMQuesttokenIn,
        uint256 mGamecoinRewardfactor,
        uint256 gamecoinOutScoremultiplier,
        address gamecoinOut
    ) internal view returns (uint256) {
        uint256 amount1e18 = (amountMQuesttokenIn * mGamecoinRewardfactor) / gamecoinOutScoremultiplier;

        uint256 goldtokenUnit = 10 ** IERC20Metadata(gamecoinOut).decimals();

        return amount1e18 * goldtokenUnit / 1e18;
    }
}