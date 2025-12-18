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

    bytes32 public constant override _0xd53232 = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0xe2f201 = 3_10;

    address public immutable _0xd51bc4;
    address public immutable _0xfebc62;

    mapping(address => PendingRedemption) public _0x8c917f;

    /// @notice Constructor
    /// @param _midasRedemptionVault Address of the Midas Redemption Vault
    constructor(address _0xc64d52) {
        _0xd51bc4 = _0xc64d52;
        _0xfebc62 = IMidasRedemptionVault(_0xc64d52)._0xfebc62();
    }

    /// @notice Performs instant redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    /// @dev Transfers mToken from sender, redeems, and transfers output token back
    function _0x30d4fb(address _0x519e27, uint256 _0xb10a0a, uint256 _0xfe134f) external _0xb3483e {
        IERC20(_0xfebc62)._0x5a606b(msg.sender, address(this), _0xb10a0a);

        uint256 _0xa95b17 = IERC20(_0x519e27)._0x18dfc1(address(this));

        IERC20(_0xfebc62)._0xd352dc(_0xd51bc4, _0xb10a0a);
        IMidasRedemptionVault(_0xd51bc4)._0x30d4fb(_0x519e27, _0xb10a0a, _0xfe134f);

        uint256 _0xc896c4 = IERC20(_0x519e27)._0x18dfc1(address(this)) - _0xa95b17;

        IERC20(_0x519e27)._0x60c54a(msg.sender, _0xc896c4);
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token to receive
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Stores the request ID and timestamp for tracking
    function _0xc3eec8(address _0x519e27, uint256 _0xb10a0a) external _0xb3483e {
        if (_0x8c917f[msg.sender]._0xb974af) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 _0xfeae55 = IMidasRedemptionVault(_0xd51bc4)._0x42fef2();

        IERC20(_0xfebc62)._0x5a606b(msg.sender, address(this), _0xb10a0a);

        IERC20(_0xfebc62)._0xd352dc(_0xd51bc4, _0xb10a0a);
        IMidasRedemptionVault(_0xd51bc4)._0x9aa35b(_0x519e27, _0xb10a0a);

        _0x8c917f[msg.sender] =
            PendingRedemption({_0xb974af: true, _0xfeae55: _0xfeae55, timestamp: block.timestamp, _0x1bed75: 0});
    }

    /// @notice Withdraws tokens from a fulfilled redemption request
    /// @param amount Amount of output token to withdraw
    /// @dev Supports partial withdrawals by tracking remainder
    function _0xcc1507(uint256 _0xc896c4) external _0xb3483e {
        PendingRedemption memory _0xa48289 = _0x8c917f[msg.sender];

        if (!_0xa48289._0xb974af) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address _0x519e27,
            uint8 _0x48b7e2,
            uint256 _0xb10a0a,
            uint256 _0xd9a011,
            uint256 _0x1913e9
        ) = IMidasRedemptionVault(_0xd51bc4)._0x227059(_0xa48289._0xfeae55);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (_0x48b7e2 != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 _0x17fe3d;

        if (_0xa48289._0x1bed75 > 0) {
            _0x17fe3d = _0xa48289._0x1bed75;
        } else {
            _0x17fe3d = _0xddd953(_0xb10a0a, _0xd9a011, _0x1913e9, _0x519e27);
        }

        if (_0xc896c4 > _0x17fe3d) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (_0xc896c4 == _0x17fe3d) {
            delete _0x8c917f[msg.sender];
        } else {
            _0x8c917f[msg.sender]._0x1bed75 = _0x17fe3d - _0xc896c4;
        }

        IERC20(_0x519e27)._0x60c54a(msg.sender, _0xc896c4);
    }

    /// @notice Returns the expected amount of output token for a user's pending redemption
    /// @param user User address to check
    /// @param tokenOut Output token to check
    /// @return Expected amount of output token, considering any partial withdrawals
    function _0xbc4e61(address _0xbae689, address _0x519e27) external view returns (uint256) {
        PendingRedemption memory _0xa48289 = _0x8c917f[_0xbae689];

        if (!_0xa48289._0xb974af) {
            return 0;
        }

        (address sender, address _0x6c6420,, uint256 _0xb10a0a, uint256 _0xd9a011, uint256 _0x1913e9) =
            IMidasRedemptionVault(_0xd51bc4)._0x227059(_0xa48289._0xfeae55);

        if (sender != address(this) || _0x6c6420 != _0x519e27) {
            return 0;
        }

        if (_0xa48289._0x1bed75 > 0) {
            return _0xa48289._0x1bed75;
        } else {
            return _0xddd953(_0xb10a0a, _0xd9a011, _0x1913e9, _0x519e27);
        }
    }

    /// @dev Calculates the output token amount from mToken amount and rates
    /// @param amountMTokenIn Amount of mToken
    /// @param mTokenRate Rate of mToken
    /// @param tokenOutRate Rate of output token
    /// @param tokenOut Address of output token
    /// @return Amount of output token in its native decimals
    function _0xddd953(
        uint256 _0xb10a0a,
        uint256 _0xd9a011,
        uint256 _0x1913e9,
        address _0x519e27
    ) internal view returns (uint256) {
        uint256 _0x7be1ff = (_0xb10a0a * _0xd9a011) / _0x1913e9;

        uint256 _0x360f57 = 10 ** IERC20Metadata(_0x519e27)._0x10ca96();

        return _0x7be1ff * _0x360f57 / 1e18;
    }
}