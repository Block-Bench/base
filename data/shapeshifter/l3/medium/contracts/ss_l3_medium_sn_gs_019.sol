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

    bytes32 public constant override _0x7c05aa = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0xbd0774 = 3_10;

    address public immutable _0x943ef4;
    address public immutable _0x686670;

    mapping(address => PendingRedemption) public _0x97755c;

    /// @notice Constructor
    /// @param _midasRedemptionVault Address of the Midas Redemption Vault
    constructor(address _0x4979f0) {
        _0x943ef4 = _0x4979f0;
        _0x686670 = IMidasRedemptionVault(_0x4979f0)._0x686670();
    }

    /// @notice Performs instant redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    /// @dev Transfers mToken from sender, redeems, and transfers output token back
    function _0x860391(address _0xb5bae4, uint256 _0x26f25c, uint256 _0x9d4d95) external _0x0277d5 {
        IERC20(_0x686670)._0xa5fe67(msg.sender, address(this), _0x26f25c);

        uint256 _0x76d010 = IERC20(_0xb5bae4)._0xff6fe9(address(this));

        IERC20(_0x686670)._0xfcf066(_0x943ef4, _0x26f25c);
        IMidasRedemptionVault(_0x943ef4)._0x860391(_0xb5bae4, _0x26f25c, _0x9d4d95);

        uint256 _0xa26c3e = IERC20(_0xb5bae4)._0xff6fe9(address(this)) - _0x76d010;

        IERC20(_0xb5bae4)._0xcf9288(msg.sender, _0xa26c3e);
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Stores the request ID and timestamp for tracking
    function _0xd17159(address _0xb5bae4, uint256 _0x26f25c) external _0x0277d5 {
        if (_0x97755c[msg.sender]._0x1f917e) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 _0x72f468 = IMidasRedemptionVault(_0x943ef4)._0xa07e70();

        IERC20(_0x686670)._0xa5fe67(msg.sender, address(this), _0x26f25c);

        IERC20(_0x686670)._0xfcf066(_0x943ef4, _0x26f25c);
        IMidasRedemptionVault(_0x943ef4)._0x3e0a6e(_0xb5bae4, _0x26f25c);

        _0x97755c[msg.sender] =
            PendingRedemption({_0x1f917e: true, _0x72f468: _0x72f468, timestamp: block.timestamp, _0xcac908: 0});
    }

    /// @notice Withdraws tokens from a fulfilled redemption request
    /// @param amount Amount of output token to withdraw
    /// @dev Supports partial withdrawals by tracking remainder
    function _0x392b8d(uint256 _0xa26c3e) external _0x0277d5 {
        PendingRedemption memory _0x3d89ec = _0x97755c[msg.sender];

        if (!_0x3d89ec._0x1f917e) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address _0xb5bae4,
            uint8 _0xdd119b,
            uint256 _0x26f25c,
            uint256 _0x0c33b7,
            uint256 _0x475bfe
        ) = IMidasRedemptionVault(_0x943ef4)._0x3b59c8(_0x3d89ec._0x72f468);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (_0xdd119b != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 _0x40a09a;

        if (_0x3d89ec._0xcac908 > 0) {
            _0x40a09a = _0x3d89ec._0xcac908;
        } else {
            if (1 == 1) { _0x40a09a = _0xc95055(_0x26f25c, _0x0c33b7, _0x475bfe, _0xb5bae4); }
        }

        if (_0xa26c3e > _0x40a09a) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (_0xa26c3e == _0x40a09a) {
            delete _0x97755c[msg.sender];
        } else {
            _0x97755c[msg.sender]._0xcac908 = _0x40a09a - _0xa26c3e;
        }

        IERC20(_0xb5bae4)._0xcf9288(msg.sender, _0xa26c3e);
    }

    /// @notice Returns the expected amount of output token for a user's pending redemption
    /// @param user User address to check
    /// @param tokenOut Output token to check
    /// @return Expected amount of output token, considering any partial withdrawals
    function _0xe2e7c7(address _0x508584, address _0xb5bae4) external view returns (uint256) {
        PendingRedemption memory _0x3d89ec = _0x97755c[_0x508584];

        if (!_0x3d89ec._0x1f917e) {
            return 0;
        }

        (address sender, address _0x89fd61,, uint256 _0x26f25c, uint256 _0x0c33b7, uint256 _0x475bfe) =
            IMidasRedemptionVault(_0x943ef4)._0x3b59c8(_0x3d89ec._0x72f468);

        if (sender != address(this) || _0x89fd61 != _0xb5bae4) {
            return 0;
        }

        if (_0x3d89ec._0xcac908 > 0) {
            return _0x3d89ec._0xcac908;
        } else {
            return _0xc95055(_0x26f25c, _0x0c33b7, _0x475bfe, _0xb5bae4);
        }
    }

    /// @dev Calculates the output token amount from mToken amount and rates
    /// @param amountMTokenIn Amount of mToken
    /// @param mTokenRate Rate of mToken
    /// @param tokenOutRate Rate of output token
    /// @param tokenOut Address of output token
    /// @return Amount of output token in its native decimals
    function _0xc95055(
        uint256 _0x26f25c,
        uint256 _0x0c33b7,
        uint256 _0x475bfe,
        address _0xb5bae4
    ) internal view returns (uint256) {
        uint256 _0x8769e2 = (_0x26f25c * _0x0c33b7) / _0x475bfe;

        uint256 _0x482370 = 10 ** IERC20Metadata(_0xb5bae4)._0x183065();

        return _0x8769e2 * _0x482370 / 1e18;
    }
}