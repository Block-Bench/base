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

    bytes32 public constant override _0x10b7df = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0x207233 = 3_10;

    /// @notice mToken
    address public immutable override _0x80cf09;

    /// @notice Gateway address
    address public immutable override _0x4eddd8;

    /// @notice Mapping from phantom token to its tracked output token
    mapping(address => address) public _0xdc9c27;

    /// @notice Mapping from output token to its tracked phantom token
    mapping(address => address) public _0xfc1631;

    /// @dev Set of allowed output tokens for redemptions
    EnumerableSet.AddressSet internal _0x755cc6;

    /// @notice Constructor
    /// @param _creditManager Credit manager address
    /// @param _gateway Midas Redemption Vault gateway address
    constructor(address _0x398bbb, address _0x951dcb) AbstractAdapter(_0x398bbb, _0x951dcb) {
        _0x4eddd8 = _0x951dcb;
        _0x80cf09 = IMidasRedemptionVaultGateway(_0x951dcb)._0x80cf09();

        _0x131226(_0x80cf09);
    }

    /// @notice Instantly redeems mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    function _0xcdb5e6(address _0x1a3bf6, uint256 _0x0f616c, uint256 _0xb12d8a)
        external
        override
        _0xb52eef
        returns (bool)
    {
        if (!_0xac26bf(_0x1a3bf6)) revert TokenNotAllowedException();

        _0x37bbeb(_0x1a3bf6, _0x0f616c, _0xb12d8a);

        return false;
    }

    /// @notice Instantly redeems the entire balance of mToken for output token, except the specified amount
    /// @param tokenOut Output token address
    /// @param leftoverAmount Amount of mToken to keep in the account
    /// @param rateMinRAY Minimum exchange rate from input token to mToken (in RAY format)
    function _0x727bac(address _0x1a3bf6, uint256 _0x4471fe, uint256 _0x345259)
        external
        override
        _0xb52eef
        returns (bool)
    {
        if (!_0xac26bf(_0x1a3bf6)) revert TokenNotAllowedException();

        address _0x5f616c = _0xf4d127();

        uint256 balance = IERC20(_0x80cf09)._0x28d8be(_0x5f616c);
        if (balance > _0x4471fe) {
            unchecked {
                uint256 _0xbd05c4 = balance - _0x4471fe;
                uint256 _0xb12d8a = (_0xbd05c4 * _0x345259) / RAY;
                _0x37bbeb(_0x1a3bf6, _0xbd05c4, _0xb12d8a);
            }
        }
        return false;
    }

    /// @dev Internal implementation of redeemInstant
    function _0x37bbeb(address _0x1a3bf6, uint256 _0x0f616c, uint256 _0xb12d8a) internal {
        _0x9e2d94(
            _0x80cf09,
            abi._0x269ac8(
                IMidasRedemptionVaultGateway._0xcdb5e6,
                (_0x1a3bf6, _0x0f616c, _0x266bb2(_0xb12d8a, _0x1a3bf6))
            )
        );
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Returns `true` to allow safe pricing for the withdrawal phantom token
    function _0xc878f4(address _0x1a3bf6, uint256 _0x0f616c)
        external
        override
        _0xb52eef
        returns (bool)
    {
        if (!_0xac26bf(_0x1a3bf6) || _0xfc1631[_0x1a3bf6] == address(0)) {
            revert TokenNotAllowedException();
        }

        _0x9e2d94(
            _0x80cf09, abi._0x269ac8(IMidasRedemptionVaultGateway._0xc1e8a2, (_0x1a3bf6, _0x0f616c))
        );
        return true;
    }

    /// @notice Withdraws redeemed tokens from the gateway
    /// @param amount Amount to withdraw
    function _0x541ff2(uint256 _0xbd05c4) external override _0xb52eef returns (bool) {
        _0xfc7f32(_0xbd05c4);
        return false;
    }

    /// @dev Internal implementation of withdraw
    function _0xfc7f32(uint256 _0xbd05c4) internal {
        _0xe0cf8c(abi._0x269ac8(IMidasRedemptionVaultGateway._0x541ff2, (_0xbd05c4)));
    }

    /// @notice Withdraws phantom token balance
    /// @param token Phantom token address
    /// @param amount Amount to withdraw
    function _0xc7d903(address _0xed4ad6, uint256 _0xbd05c4) external override _0xb52eef returns (bool) {
        if (_0xdc9c27[_0xed4ad6] == address(0)) revert IncorrectStakedPhantomTokenException();
        _0xfc7f32(_0xbd05c4);
        return false;
    }

    /// @notice Deposits phantom token (not implemented for redemption vaults)
    /// @return Never returns (always reverts)
    /// @dev Redemption vaults only support withdrawals, not deposits
    function _0x58dd83(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }

    /// @dev Converts the token amount to 18 decimals, which is accepted by Midas
    function _0x266bb2(uint256 _0xbd05c4, address _0xed4ad6) internal view returns (uint256) {
        uint256 _0xa70272 = 10 ** IERC20Metadata(_0xed4ad6)._0xb24dbe();
        return _0xbd05c4 * WAD / _0xa70272;
    }

    /// @notice Returns whether a token is allowed as output for redemptions
    /// @param token Token address to check
    /// @return True if token is allowed
    function _0xac26bf(address _0xed4ad6) public view override returns (bool) {
        return _0x755cc6._0xf0533e(_0xed4ad6);
    }

    /// @notice Returns all allowed output tokens
    /// @return Array of allowed token addresses
    function _0x814062() public view override returns (address[] memory) {
        return _0x755cc6._0xa40c0e();
    }

    /// @notice Sets the allowed status for a batch of output tokens
    /// @param configs Array of MidasAllowedTokenStatus structs
    /// @dev Can only be called by the configurator
    function _0xabce2e(MidasAllowedTokenStatus[] calldata _0xe4e3fc)
        external
        override
        _0x9c86a1
    {
        uint256 _0x94f0e1 = _0xe4e3fc.length;

        for (uint256 i; i < _0x94f0e1; ++i) {
            MidasAllowedTokenStatus memory _0xc5c0ef = _0xe4e3fc[i];

            if (_0xc5c0ef._0x16b502) {
                _0x131226(_0xc5c0ef._0xed4ad6);
                _0x755cc6._0x1aef01(_0xc5c0ef._0xed4ad6);

                if (_0xc5c0ef._0x0832a4 != address(0)) {
                    _0x131226(_0xc5c0ef._0x0832a4);
                    _0xdc9c27[_0xc5c0ef._0x0832a4] = _0xc5c0ef._0xed4ad6;
                    _0xfc1631[_0xc5c0ef._0xed4ad6] = _0xc5c0ef._0x0832a4;
                }
            } else {
                _0x755cc6._0xf8944b(_0xc5c0ef._0xed4ad6);

                address _0x0832a4 = _0xfc1631[_0xc5c0ef._0xed4ad6];

                if (_0x0832a4 != address(0)) {
                    delete _0xfc1631[_0xc5c0ef._0xed4ad6];
                    delete _0xdc9c27[_0x0832a4];
                }
            }

            emit SetTokenAllowedStatus(_0xc5c0ef._0xed4ad6, _0xc5c0ef._0x0832a4, _0xc5c0ef._0x16b502);
        }
    }

    /// @notice Serialized adapter parameters
    /// @return serializedData Encoded adapter configuration
    function _0x769acb() external view returns (bytes memory _0xb481ca) {
        _0xb481ca = abi._0xa530f1(_0x74563a, _0x80a57d, _0x4eddd8, _0x80cf09, _0x814062());
    }
}