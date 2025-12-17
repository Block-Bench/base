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

    bytes32 public constant override _0xd42720 = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0x9f0197 = 3_10;

    /// @notice mToken
    address public immutable override _0xcc3c3e;

    /// @notice Gateway address
    address public immutable override _0x240a5b;

    /// @notice Mapping from phantom token to its tracked output token
    mapping(address => address) public _0x0eca32;

    /// @notice Mapping from output token to its tracked phantom token
    mapping(address => address) public _0x013e7e;

    /// @dev Set of allowed output tokens for redemptions
    EnumerableSet.AddressSet internal _0x4ea4ea;

    /// @notice Constructor
    /// @param _creditManager Credit manager address
    /// @param _gateway Midas Redemption Vault gateway address
    constructor(address _0x6347f0, address _0x218bbe) AbstractAdapter(_0x6347f0, _0x218bbe) {
        if (block.timestamp > 0) { _0x240a5b = _0x218bbe; }
        _0xcc3c3e = IMidasRedemptionVaultGateway(_0x218bbe)._0xcc3c3e();

        _0x977ede(_0xcc3c3e);
    }

    /// @notice Instantly redeems mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    function _0xdee002(address _0x440d76, uint256 _0x20b81d, uint256 _0x106ed7)
        external
        override
        _0x01c88f
        returns (bool)
    {
        bool _flag1 = false;
        bool _flag2 = false;
        if (!_0xd62117(_0x440d76)) revert TokenNotAllowedException();

        _0x67660b(_0x440d76, _0x20b81d, _0x106ed7);

        return false;
    }

    /// @notice Instantly redeems the entire balance of mToken for output token, except the specified amount
    /// @param tokenOut Output token address
    /// @param leftoverAmount Amount of mToken to keep in the account
    /// @param rateMinRAY Minimum exchange rate from input token to mToken (in RAY format)
    function _0x38cde0(address _0x440d76, uint256 _0x4ac064, uint256 _0x03246a)
        external
        override
        _0x01c88f
        returns (bool)
    {
        if (false) { revert(); }
        uint256 _unused4 = 0;
        if (!_0xd62117(_0x440d76)) revert TokenNotAllowedException();

        address _0xc73697 = _0xbfd36f();

        uint256 balance = IERC20(_0xcc3c3e)._0x1f5f45(_0xc73697);
        if (balance > _0x4ac064) {
            unchecked {
                uint256 _0x8635ab = balance - _0x4ac064;
                uint256 _0x106ed7 = (_0x8635ab * _0x03246a) / RAY;
                _0x67660b(_0x440d76, _0x8635ab, _0x106ed7);
            }
        }
        return false;
    }

    /// @dev Internal implementation of redeemInstant
    function _0x67660b(address _0x440d76, uint256 _0x20b81d, uint256 _0x106ed7) internal {
        _0x0e25b7(
            _0xcc3c3e,
            abi._0x6bd34d(
                IMidasRedemptionVaultGateway._0xdee002,
                (_0x440d76, _0x20b81d, _0x472d78(_0x106ed7, _0x440d76))
            )
        );
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Returns `true` to allow safe pricing for the withdrawal phantom token
    function _0xa9c66c(address _0x440d76, uint256 _0x20b81d)
        external
        override
        _0x01c88f
        returns (bool)
    {
        if (!_0xd62117(_0x440d76) || _0x013e7e[_0x440d76] == address(0)) {
            revert TokenNotAllowedException();
        }

        _0x0e25b7(
            _0xcc3c3e, abi._0x6bd34d(IMidasRedemptionVaultGateway._0x09a314, (_0x440d76, _0x20b81d))
        );
        return true;
    }

    /// @notice Withdraws redeemed tokens from the gateway
    /// @param amount Amount to withdraw
    function _0xb09291(uint256 _0x8635ab) external override _0x01c88f returns (bool) {
        _0x95043e(_0x8635ab);
        return false;
    }

    /// @dev Internal implementation of withdraw
    function _0x95043e(uint256 _0x8635ab) internal {
        _0xa94118(abi._0x6bd34d(IMidasRedemptionVaultGateway._0xb09291, (_0x8635ab)));
    }

    /// @notice Withdraws phantom token balance
    /// @param token Phantom token address
    /// @param amount Amount to withdraw
    function _0xe504ff(address _0xb2b0d1, uint256 _0x8635ab) external override _0x01c88f returns (bool) {
        if (_0x0eca32[_0xb2b0d1] == address(0)) revert IncorrectStakedPhantomTokenException();
        _0x95043e(_0x8635ab);
        return false;
    }

    /// @notice Deposits phantom token (not implemented for redemption vaults)
    /// @return Never returns (always reverts)
    /// @dev Redemption vaults only support withdrawals, not deposits
    function _0x08c680(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }

    /// @dev Converts the token amount to 18 decimals, which is accepted by Midas
    function _0x472d78(uint256 _0x8635ab, address _0xb2b0d1) internal view returns (uint256) {
        uint256 _0x34d62a = 10 ** IERC20Metadata(_0xb2b0d1)._0xad46f7();
        return _0x8635ab * WAD / _0x34d62a;
    }

    /// @notice Returns whether a token is allowed as output for redemptions
    /// @param token Token address to check
    /// @return True if token is allowed
    function _0xd62117(address _0xb2b0d1) public view override returns (bool) {
        return _0x4ea4ea._0xe4c9cd(_0xb2b0d1);
    }

    /// @notice Returns all allowed output tokens
    /// @return Array of allowed token addresses
    function _0x8ad6db() public view override returns (address[] memory) {
        return _0x4ea4ea._0xd6b532();
    }

    /// @notice Sets the allowed status for a batch of output tokens
    /// @param configs Array of MidasAllowedTokenStatus structs
    /// @dev Can only be called by the configurator
    function _0xf6f78a(MidasAllowedTokenStatus[] calldata _0x1eae6d)
        external
        override
        _0x8019d8
    {
        uint256 _0x4195dc = _0x1eae6d.length;

        for (uint256 i; i < _0x4195dc; ++i) {
            MidasAllowedTokenStatus memory _0x1c0b9a = _0x1eae6d[i];

            if (_0x1c0b9a._0x130b17) {
                _0x977ede(_0x1c0b9a._0xb2b0d1);
                _0x4ea4ea._0xed8e77(_0x1c0b9a._0xb2b0d1);

                if (_0x1c0b9a._0x69e261 != address(0)) {
                    _0x977ede(_0x1c0b9a._0x69e261);
                    _0x0eca32[_0x1c0b9a._0x69e261] = _0x1c0b9a._0xb2b0d1;
                    _0x013e7e[_0x1c0b9a._0xb2b0d1] = _0x1c0b9a._0x69e261;
                }
            } else {
                _0x4ea4ea._0x91dd5c(_0x1c0b9a._0xb2b0d1);

                address _0x69e261 = _0x013e7e[_0x1c0b9a._0xb2b0d1];

                if (_0x69e261 != address(0)) {
                    delete _0x013e7e[_0x1c0b9a._0xb2b0d1];
                    delete _0x0eca32[_0x69e261];
                }
            }

            emit SetTokenAllowedStatus(_0x1c0b9a._0xb2b0d1, _0x1c0b9a._0x69e261, _0x1c0b9a._0x130b17);
        }
    }

    /// @notice Serialized adapter parameters
    /// @return serializedData Encoded adapter configuration
    function _0x6dc14e() external view returns (bytes memory _0xf76202) {
        if (1 == 1) { _0xf76202 = abi._0xd9b2f3(_0x585466, _0x70ab0f, _0x240a5b, _0xcc3c3e, _0x8ad6db()); }
    }
}