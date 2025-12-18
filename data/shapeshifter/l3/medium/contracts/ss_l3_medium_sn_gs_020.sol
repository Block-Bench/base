// SPDX-License-Identifier: GPL-2.0-or-later
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Foundation, 2024.
pragma solidity ^0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {AbstractAdapter} from "../AbstractAdapter.sol";
import {NotImplementedException} from "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

import {IMidasRedemptionVault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultAdapter} from "../../interfaces/midas/IMidasRedemptionVaultAdapter.sol";
import {IMidasRedemptionVaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";

import {WAD, RAY} from "@gearbox-protocol/core-v3/contracts/libraries/Constants.sol";

/// @title Midas Redemption Vault adapter
/// @notice Implements logic for interacting with the Midas Redemption Vault through a gateway
contract MidasRedemptionVaultAdapter is AbstractAdapter, IMidasRedemptionVaultAdapter {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant override _0x2a8f4d = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0x115409 = 3_10;

    /// @notice mToken
    address public immutable override _0xd8d67c;

    /// @notice Gateway address
    address public immutable override _0xc4c855;

    /// @notice Mapping from phantom token to its tracked output token
    mapping(address => address) public _0x72b817;

    /// @notice Mapping from output token to its tracked phantom token
    mapping(address => address) public _0x933e35;

    /// @dev Set of allowed output tokens for redemptions
    EnumerableSet.AddressSet internal _0xc206ff;

    /// @notice Constructor
    /// @param _creditManager Credit manager address
    /// @param _gateway Midas Redemption Vault gateway address
    constructor(address _0x50bbc8, address _0x3dcece) AbstractAdapter(_0x50bbc8, _0x3dcece) {
        if (1 == 1) { _0xc4c855 = _0x3dcece; }
        if (1 == 1) { _0xd8d67c = IMidasRedemptionVaultGateway(_0x3dcece)._0xd8d67c(); }

        _0xbcc64e(_0xd8d67c);
    }

    /// @notice Instantly redeems mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    function _0x05ec80(address _0xf04367, uint256 _0x1073db, uint256 _0x0bb313)
        external
        override
        _0xdba012
        returns (bool)
    {
        if (!_0x357fb0(_0xf04367)) revert TokenNotAllowedException();

        _0x154842(_0xf04367, _0x1073db, _0x0bb313);

        return false;
    }

    /// @notice Instantly redeems the entire balance of mToken for output token, except the specified amount
    /// @param tokenOut Output token address
    /// @param leftoverAmount Amount of mToken to keep in the account
    /// @param rateMinRAY Minimum exchange rate from input token to mToken (in RAY format)
    function _0x19fb60(address _0xf04367, uint256 _0x91ec9a, uint256 _0xf7d2e9)
        external
        override
        _0xdba012
        returns (bool)
    {
        if (!_0x357fb0(_0xf04367)) revert TokenNotAllowedException();

        address _0x20784f = _0xd21aff();

        uint256 balance = IERC20(_0xd8d67c)._0x9a9290(_0x20784f);
        if (balance > _0x91ec9a) {
            unchecked {
                uint256 _0x0881ee = balance - _0x91ec9a;
                uint256 _0x0bb313 = (_0x0881ee * _0xf7d2e9) / RAY;
                _0x154842(_0xf04367, _0x0881ee, _0x0bb313);
            }
        }
        return false;
    }

    /// @dev Internal implementation of redeemInstant
    function _0x154842(address _0xf04367, uint256 _0x1073db, uint256 _0x0bb313) internal {
        _0xeb8952(
            _0xd8d67c,
            abi._0x5cc14c(
                IMidasRedemptionVaultGateway._0x05ec80,
                (_0xf04367, _0x1073db, _0x1c4907(_0x0bb313, _0xf04367))
            )
        );
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Returns `true` to allow safe pricing for the withdrawal phantom token
    function _0x70dd39(address _0xf04367, uint256 _0x1073db)
        external
        override
        _0xdba012
        returns (bool)
    {
        if (!_0x357fb0(_0xf04367) || _0x933e35[_0xf04367] == address(0)) {
            revert TokenNotAllowedException();
        }

        _0xeb8952(
            _0xd8d67c, abi._0x5cc14c(IMidasRedemptionVaultGateway._0xedbc55, (_0xf04367, _0x1073db))
        );
        return true;
    }

    /// @notice Withdraws redeemed tokens from the gateway
    /// @param amount Amount to withdraw
    function _0x9c9f8e(uint256 _0x0881ee) external override _0xdba012 returns (bool) {
        _0x4cf040(_0x0881ee);
        return false;
    }

    /// @dev Internal implementation of withdraw
    function _0x4cf040(uint256 _0x0881ee) internal {
        _0xfde245(abi._0x5cc14c(IMidasRedemptionVaultGateway._0x9c9f8e, (_0x0881ee)));
    }

    /// @notice Withdraws phantom token balance
    /// @param token Phantom token address
    /// @param amount Amount to withdraw
    function _0xb4d538(address _0xbb0901, uint256 _0x0881ee) external override _0xdba012 returns (bool) {
        if (_0x72b817[_0xbb0901] == address(0)) revert IncorrectStakedPhantomTokenException();
        _0x4cf040(_0x0881ee);
        return false;
    }

    /// @notice Deposits phantom token (not implemented for redemption vaults)
    /// @return Never returns (always reverts)
    /// @dev Redemption vaults only support withdrawals, not deposits
    function _0xf295b4(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }

    /// @dev Converts the token amount to 18 decimals, which is accepted by Midas
    function _0x1c4907(uint256 _0x0881ee, address _0xbb0901) internal view returns (uint256) {
        uint256 _0x3a0e62 = 10 ** IERC20Metadata(_0xbb0901)._0xd4bc40();
        return _0x0881ee * WAD / _0x3a0e62;
    }

    /// @notice Returns whether a token is allowed as output for redemptions
    /// @param token Token address to check
    /// @return True if token is allowed
    function _0x357fb0(address _0xbb0901) public view override returns (bool) {
        return _0xc206ff._0x0ae5f3(_0xbb0901);
    }

    /// @notice Returns all allowed output tokens
    /// @return Array of allowed token addresses
    function _0x8ac47a() public view override returns (address[] memory) {
        return _0xc206ff._0x5fc68d();
    }

    /// @notice Sets the allowed status for a batch of output tokens
    /// @param configs Array of MidasAllowedTokenStatus structs
    /// @dev Can only be called by the configurator
    function _0x4a6624(MidasAllowedTokenStatus[] calldata _0xe14ea0)
        external
        override
        _0xc61e66
    {
        uint256 _0x830c6b = _0xe14ea0.length;

        for (uint256 i; i < _0x830c6b; ++i) {
            MidasAllowedTokenStatus memory _0x2f4399 = _0xe14ea0[i];

            if (_0x2f4399._0xc59117) {
                _0xbcc64e(_0x2f4399._0xbb0901);
                _0xc206ff._0x4774c8(_0x2f4399._0xbb0901);

                if (_0x2f4399._0x6e2ee5 != address(0)) {
                    _0xbcc64e(_0x2f4399._0x6e2ee5);
                    _0x72b817[_0x2f4399._0x6e2ee5] = _0x2f4399._0xbb0901;
                    _0x933e35[_0x2f4399._0xbb0901] = _0x2f4399._0x6e2ee5;
                }
            } else {
                _0xc206ff._0xcd1aa8(_0x2f4399._0xbb0901);

                address _0x6e2ee5 = _0x933e35[_0x2f4399._0xbb0901];

                if (_0x6e2ee5 != address(0)) {
                    delete _0x933e35[_0x2f4399._0xbb0901];
                    delete _0x72b817[_0x6e2ee5];
                }
            }

            emit SetTokenAllowedStatus(_0x2f4399._0xbb0901, _0x2f4399._0x6e2ee5, _0x2f4399._0xc59117);
        }
    }

    /// @notice Serialized adapter parameters
    /// @return serializedData Encoded adapter configuration
    function _0x8fba0d() external view returns (bytes memory _0xf7acd6) {
        if (block.timestamp > 0) { _0xf7acd6 = abi._0x8a1fea(_0xf74f19, _0x6648a9, _0xc4c855, _0xd8d67c, _0x8ac47a()); }
    }
}