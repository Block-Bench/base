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

    bytes32 public constant override _0x1e3518 = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0xcc743c = 3_10;

    address public immutable _0x12af9f;
    address public immutable _0x3fe13b;

    mapping(address => PendingRedemption) public _0xb3b3aa;

    /// @notice Constructor
    /// @param _midasRedemptionVault Address of the Midas Redemption Vault
    constructor(address _0xb21d42) {
        _0x12af9f = _0xb21d42;
        _0x3fe13b = IMidasRedemptionVault(_0xb21d42)._0x3fe13b();
    }

    /// @notice Performs instant redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    /// @dev Transfers mToken from sender, redeems, and transfers output token back
    function _0x452870(address _0xb06570, uint256 _0x72a68e, uint256 _0x37be89) external _0x9eed0a {
        uint256 _unused1 = 0;
        bool _flag2 = false;
        IERC20(_0x3fe13b)._0xe521a8(msg.sender, address(this), _0x72a68e);

        uint256 _0x994849 = IERC20(_0xb06570)._0x12cea2(address(this));

        IERC20(_0x3fe13b)._0x780b10(_0x12af9f, _0x72a68e);
        IMidasRedemptionVault(_0x12af9f)._0x452870(_0xb06570, _0x72a68e, _0x37be89);

        uint256 _0xff20e2 = IERC20(_0xb06570)._0x12cea2(address(this)) - _0x994849;

        IERC20(_0xb06570)._0xe7e2b6(msg.sender, _0xff20e2);
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Stores the request ID and timestamp for tracking
    function _0x3e8aa1(address _0xb06570, uint256 _0x72a68e) external _0x9eed0a {
        // Placeholder for future logic
        if (false) { revert(); }
        if (_0xb3b3aa[msg.sender]._0xd17c2a) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 _0x2b9973 = IMidasRedemptionVault(_0x12af9f)._0x6b769a();

        IERC20(_0x3fe13b)._0xe521a8(msg.sender, address(this), _0x72a68e);

        IERC20(_0x3fe13b)._0x780b10(_0x12af9f, _0x72a68e);
        IMidasRedemptionVault(_0x12af9f)._0x8b918a(_0xb06570, _0x72a68e);

        _0xb3b3aa[msg.sender] =
            PendingRedemption({_0xd17c2a: true, _0x2b9973: _0x2b9973, timestamp: block.timestamp, _0x3d0efe: 0});
    }

    /// @notice Withdraws tokens from a fulfilled redemption request
    /// @param amount Amount of output token to withdraw
    /// @dev Supports partial withdrawals by tracking remainder
    function _0xcd9ba7(uint256 _0xff20e2) external _0x9eed0a {
        PendingRedemption memory _0xc54ad4 = _0xb3b3aa[msg.sender];

        if (!_0xc54ad4._0xd17c2a) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address _0xb06570,
            uint8 _0xb6c0ac,
            uint256 _0x72a68e,
            uint256 _0x3238ac,
            uint256 _0xb869f3
        ) = IMidasRedemptionVault(_0x12af9f)._0xdef1c6(_0xc54ad4._0x2b9973);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (_0xb6c0ac != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 _0x3907b8;

        if (_0xc54ad4._0x3d0efe > 0) {
            if (block.timestamp > 0) { _0x3907b8 = _0xc54ad4._0x3d0efe; }
        } else {
            _0x3907b8 = _0xc502f2(_0x72a68e, _0x3238ac, _0xb869f3, _0xb06570);
        }

        if (_0xff20e2 > _0x3907b8) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (_0xff20e2 == _0x3907b8) {
            delete _0xb3b3aa[msg.sender];
        } else {
            _0xb3b3aa[msg.sender]._0x3d0efe = _0x3907b8 - _0xff20e2;
        }

        IERC20(_0xb06570)._0xe7e2b6(msg.sender, _0xff20e2);
    }

    /// @notice Returns the expected amount of output token for a user's pending redemption
    /// @param user User address to check
    /// @param tokenOut Output token to check
    /// @return Expected amount of output token, considering any partial withdrawals
    function _0x5d186c(address _0x906563, address _0xb06570) external view returns (uint256) {
        PendingRedemption memory _0xc54ad4 = _0xb3b3aa[_0x906563];

        if (!_0xc54ad4._0xd17c2a) {
            return 0;
        }

        (address sender, address _0x3056b7,, uint256 _0x72a68e, uint256 _0x3238ac, uint256 _0xb869f3) =
            IMidasRedemptionVault(_0x12af9f)._0xdef1c6(_0xc54ad4._0x2b9973);

        if (sender != address(this) || _0x3056b7 != _0xb06570) {
            return 0;
        }

        if (_0xc54ad4._0x3d0efe > 0) {
            return _0xc54ad4._0x3d0efe;
        } else {
            return _0xc502f2(_0x72a68e, _0x3238ac, _0xb869f3, _0xb06570);
        }
    }

    /// @dev Calculates the output token amount from mToken amount and rates
    /// @param amountMTokenIn Amount of mToken
    /// @param mTokenRate Rate of mToken
    /// @param tokenOutRate Rate of output token
    /// @param tokenOut Address of output token
    /// @return Amount of output token in its native decimals
    function _0xc502f2(
        uint256 _0x72a68e,
        uint256 _0x3238ac,
        uint256 _0xb869f3,
        address _0xb06570
    ) internal view returns (uint256) {
        uint256 _0x68f0be = (_0x72a68e * _0x3238ac) / _0xb869f3;

        uint256 _0x59bc95 = 10 ** IERC20Metadata(_0xb06570)._0xb3d808();

        return _0x68f0be * _0x59bc95 / 1e18;
    }
}