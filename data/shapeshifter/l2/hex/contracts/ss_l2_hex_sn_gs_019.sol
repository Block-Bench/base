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

    bytes32 public constant override _0xee7f79 = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0x59a929 = 3_10;

    address public immutable _0xfa56ab;
    address public immutable _0xab8a0f;

    mapping(address => PendingRedemption) public _0xa2876a;

    /// @notice Constructor
    /// @param _midasRedemptionVault Address of the Midas Redemption Vault
    constructor(address _0x650329) {
        _0xfa56ab = _0x650329;
        _0xab8a0f = IMidasRedemptionVault(_0x650329)._0xab8a0f();
    }

    /// @notice Performs instant redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    /// @dev Transfers mToken from sender, redeems, and transfers output token back
    function _0x3b5ded(address _0x00eca9, uint256 _0x504b59, uint256 _0x3d87a8) external _0x62beba {
        IERC20(_0xab8a0f)._0x0a69bc(msg.sender, address(this), _0x504b59);

        uint256 _0xc9deeb = IERC20(_0x00eca9)._0x644b78(address(this));

        IERC20(_0xab8a0f)._0xc165a0(_0xfa56ab, _0x504b59);
        IMidasRedemptionVault(_0xfa56ab)._0x3b5ded(_0x00eca9, _0x504b59, _0x3d87a8);

        uint256 _0xb1b97b = IERC20(_0x00eca9)._0x644b78(address(this)) - _0xc9deeb;

        IERC20(_0x00eca9)._0x6f4d79(msg.sender, _0xb1b97b);
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Stores the request ID and timestamp for tracking
    function _0xa1e2f6(address _0x00eca9, uint256 _0x504b59) external _0x62beba {
        if (_0xa2876a[msg.sender]._0xbbcc58) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 _0x19844a = IMidasRedemptionVault(_0xfa56ab)._0xdd7801();

        IERC20(_0xab8a0f)._0x0a69bc(msg.sender, address(this), _0x504b59);

        IERC20(_0xab8a0f)._0xc165a0(_0xfa56ab, _0x504b59);
        IMidasRedemptionVault(_0xfa56ab)._0xfa4bcd(_0x00eca9, _0x504b59);

        _0xa2876a[msg.sender] =
            PendingRedemption({_0xbbcc58: true, _0x19844a: _0x19844a, timestamp: block.timestamp, _0xf9b140: 0});
    }

    /// @notice Withdraws tokens from a fulfilled redemption request
    /// @param amount Amount of output token to withdraw
    /// @dev Supports partial withdrawals by tracking remainder
    function _0x591259(uint256 _0xb1b97b) external _0x62beba {
        PendingRedemption memory _0x240634 = _0xa2876a[msg.sender];

        if (!_0x240634._0xbbcc58) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address _0x00eca9,
            uint8 _0xdf984b,
            uint256 _0x504b59,
            uint256 _0xabf260,
            uint256 _0x2b4aae
        ) = IMidasRedemptionVault(_0xfa56ab)._0x3a46f9(_0x240634._0x19844a);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (_0xdf984b != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 _0x4d3930;

        if (_0x240634._0xf9b140 > 0) {
            _0x4d3930 = _0x240634._0xf9b140;
        } else {
            _0x4d3930 = _0x6ecefc(_0x504b59, _0xabf260, _0x2b4aae, _0x00eca9);
        }

        if (_0xb1b97b > _0x4d3930) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (_0xb1b97b == _0x4d3930) {
            delete _0xa2876a[msg.sender];
        } else {
            _0xa2876a[msg.sender]._0xf9b140 = _0x4d3930 - _0xb1b97b;
        }

        IERC20(_0x00eca9)._0x6f4d79(msg.sender, _0xb1b97b);
    }

    /// @notice Returns the expected amount of output token for a user's pending redemption
    /// @param user User address to check
    /// @param tokenOut Output token to check
    /// @return Expected amount of output token, considering any partial withdrawals
    function _0x56d317(address _0x4e1e64, address _0x00eca9) external view returns (uint256) {
        PendingRedemption memory _0x240634 = _0xa2876a[_0x4e1e64];

        if (!_0x240634._0xbbcc58) {
            return 0;
        }

        (address sender, address _0xac058d,, uint256 _0x504b59, uint256 _0xabf260, uint256 _0x2b4aae) =
            IMidasRedemptionVault(_0xfa56ab)._0x3a46f9(_0x240634._0x19844a);

        if (sender != address(this) || _0xac058d != _0x00eca9) {
            return 0;
        }

        if (_0x240634._0xf9b140 > 0) {
            return _0x240634._0xf9b140;
        } else {
            return _0x6ecefc(_0x504b59, _0xabf260, _0x2b4aae, _0x00eca9);
        }
    }

    /// @dev Calculates the output token amount from mToken amount and rates
    /// @param amountMTokenIn Amount of mToken
    /// @param mTokenRate Rate of mToken
    /// @param tokenOutRate Rate of output token
    /// @param tokenOut Address of output token
    /// @return Amount of output token in its native decimals
    function _0x6ecefc(
        uint256 _0x504b59,
        uint256 _0xabf260,
        uint256 _0x2b4aae,
        address _0x00eca9
    ) internal view returns (uint256) {
        uint256 _0xb3f77b = (_0x504b59 * _0xabf260) / _0x2b4aae;

        uint256 _0xa14345 = 10 ** IERC20Metadata(_0x00eca9)._0xf6a85b();

        return _0xb3f77b * _0xa14345 / 1e18;
    }
}