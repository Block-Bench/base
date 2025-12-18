// SPDX-License-Identifier: GPL-2.0-or-later
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Foundation, 2024.
pragma solidity ^0.8.23;

import {ReentrancyGuardTrait} from "@gearbox-protocol/core-v3/contracts/traits/ReentrancyGuardTrait.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMidasRedemptionVault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";

/// @title Midas Redemption Vault Gateway
/// @notice Gateway contract that manages redemptions from Midas vault on behalf of users
/// @dev Stores pending redemption requests and handles partial withdrawals
contract MidasRedemptionVaultGateway is ReentrancyGuardTrait, IMidasRedemptionVaultGateway {
    using SafeERC20 for IERC20;

    bytes32 public constant override u = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override ag = 3_10;

    address public immutable d;
    address public immutable ah;

    mapping(address => PendingRedemption) public e;

    /// @notice Constructor
    /// @param _midasRedemptionVault Address of the Midas Redemption Vault
    constructor(address c) {
        d = c;
        ah = IMidasRedemptionVault(c).ah();
    }

    /// @notice Performs instant redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    /// @dev Transfers mToken from sender, redeems, and transfers output token back
    function m(address ac, uint256 l, uint256 h) external s {
        IERC20(ah).f(msg.sender, address(this), l);

        uint256 o = IERC20(ac).x(address(this));

        IERC20(ah).q(d, l);
        IMidasRedemptionVault(d).m(ac, l, h);

        uint256 aj = IERC20(ac).x(address(this)) - o;

        IERC20(ac).t(msg.sender, aj);
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Stores the request ID and timestamp for tracking
    function p(address ac, uint256 l) external s {
        if (e[msg.sender].ae) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 y = IMidasRedemptionVault(d).g();

        IERC20(ah).f(msg.sender, address(this), l);

        IERC20(ah).q(d, l);
        IMidasRedemptionVault(d).n(ac, l);

        e[msg.sender] =
            PendingRedemption({ae: true, y: y, timestamp: block.timestamp, z: 0});
    }

    /// @notice Withdraws tokens from a fulfilled redemption request
    /// @param amount Amount of output token to withdraw
    /// @dev Supports partial withdrawals by tracking remainder
    function ad(uint256 aj) external s {
        PendingRedemption memory af = e[msg.sender];

        if (!af.ae) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address ac,
            uint8 ai,
            uint256 l,
            uint256 w,
            uint256 r
        ) = IMidasRedemptionVault(d).k(af.y);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (ai != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 i;

        if (af.z > 0) {
            i = af.z;
        } else {
            i = a(l, w, r, ac);
        }

        if (aj > i) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (aj == i) {
            delete e[msg.sender];
        } else {
            e[msg.sender].z = i - aj;
        }

        IERC20(ac).t(msg.sender, aj);
    }

    /// @notice Returns the expected amount of output token for a user's pending redemption
    /// @param user User address to check
    /// @param tokenOut Output token to check
    /// @return Expected amount of output token, considering any partial withdrawals
    function b(address ak, address ac) external view returns (uint256) {
        PendingRedemption memory af = e[ak];

        if (!af.ae) {
            return 0;
        }

        (address sender, address j,, uint256 l, uint256 w, uint256 r) =
            IMidasRedemptionVault(d).k(af.y);

        if (sender != address(this) || j != ac) {
            return 0;
        }

        if (af.z > 0) {
            return af.z;
        } else {
            return a(l, w, r, ac);
        }
    }

    /// @dev Calculates the output token amount from mToken amount and rates
    /// @param amountMTokenIn Amount of mToken
    /// @param mTokenRate Rate of mToken
    /// @param tokenOutRate Rate of output token
    /// @param tokenOut Address of output token
    /// @return Amount of output token in its native decimals
    function a(
        uint256 l,
        uint256 w,
        uint256 r,
        address ac
    ) internal view returns (uint256) {
        uint256 v = (l * w) / r;

        uint256 aa = 10 ** IERC20Metadata(ac).ab();

        return v * aa / 1e18;
    }
}