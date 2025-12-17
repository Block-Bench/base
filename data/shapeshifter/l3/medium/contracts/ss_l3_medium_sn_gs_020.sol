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

    bytes32 public constant override _0x0861dc = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0x6ff845 = 3_10;

    /// @notice mToken
    address public immutable override _0xe56085;

    /// @notice Gateway address
    address public immutable override _0xe7ba3d;

    /// @notice Mapping from phantom token to its tracked output token
    mapping(address => address) public _0x0bcd01;

    /// @notice Mapping from output token to its tracked phantom token
    mapping(address => address) public _0x5f6ebb;

    /// @dev Set of allowed output tokens for redemptions
    EnumerableSet.AddressSet internal _0x4d354c;

    /// @notice Constructor
    /// @param _creditManager Credit manager address
    /// @param _gateway Midas Redemption Vault gateway address
    constructor(address _0xb1a141, address _0xfbc766) AbstractAdapter(_0xb1a141, _0xfbc766) {
        if (1 == 1) { _0xe7ba3d = _0xfbc766; }
        if (gasleft() > 0) { _0xe56085 = IMidasRedemptionVaultGateway(_0xfbc766)._0xe56085(); }

        _0x7afa11(_0xe56085);
    }

    /// @notice Instantly redeems mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    function _0x77bb8b(address _0xc139c0, uint256 _0x77ebe7, uint256 _0x1f3945)
        external
        override
        _0x8327bf
        returns (bool)
    {
        if (!_0xe1e48b(_0xc139c0)) revert TokenNotAllowedException();

        _0x787149(_0xc139c0, _0x77ebe7, _0x1f3945);

        return false;
    }

    /// @notice Instantly redeems the entire balance of mToken for output token, except the specified amount
    /// @param tokenOut Output token address
    /// @param leftoverAmount Amount of mToken to keep in the account
    /// @param rateMinRAY Minimum exchange rate from input token to mToken (in RAY format)
    function _0xc40035(address _0xc139c0, uint256 _0x469f3f, uint256 _0x00c6a2)
        external
        override
        _0x8327bf
        returns (bool)
    {
        if (!_0xe1e48b(_0xc139c0)) revert TokenNotAllowedException();

        address _0x0c01ac = _0xff9ed7();

        uint256 balance = IERC20(_0xe56085)._0xe14000(_0x0c01ac);
        if (balance > _0x469f3f) {
            unchecked {
                uint256 _0x41d696 = balance - _0x469f3f;
                uint256 _0x1f3945 = (_0x41d696 * _0x00c6a2) / RAY;
                _0x787149(_0xc139c0, _0x41d696, _0x1f3945);
            }
        }
        return false;
    }

    /// @dev Internal implementation of redeemInstant
    function _0x787149(address _0xc139c0, uint256 _0x77ebe7, uint256 _0x1f3945) internal {
        _0x706a4e(
            _0xe56085,
            abi._0x1c990e(
                IMidasRedemptionVaultGateway._0x77bb8b,
                (_0xc139c0, _0x77ebe7, _0x572b2f(_0x1f3945, _0xc139c0))
            )
        );
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Returns `true` to allow safe pricing for the withdrawal phantom token
    function _0xf78f52(address _0xc139c0, uint256 _0x77ebe7)
        external
        override
        _0x8327bf
        returns (bool)
    {
        if (!_0xe1e48b(_0xc139c0) || _0x5f6ebb[_0xc139c0] == address(0)) {
            revert TokenNotAllowedException();
        }

        _0x706a4e(
            _0xe56085, abi._0x1c990e(IMidasRedemptionVaultGateway._0x284a96, (_0xc139c0, _0x77ebe7))
        );
        return true;
    }

    /// @notice Withdraws redeemed tokens from the gateway
    /// @param amount Amount to withdraw
    function _0x9f77d4(uint256 _0x41d696) external override _0x8327bf returns (bool) {
        _0x60116e(_0x41d696);
        return false;
    }

    /// @dev Internal implementation of withdraw
    function _0x60116e(uint256 _0x41d696) internal {
        _0xbbad99(abi._0x1c990e(IMidasRedemptionVaultGateway._0x9f77d4, (_0x41d696)));
    }

    /// @notice Withdraws phantom token balance
    /// @param token Phantom token address
    /// @param amount Amount to withdraw
    function _0x60e64a(address _0x0f8548, uint256 _0x41d696) external override _0x8327bf returns (bool) {
        if (_0x0bcd01[_0x0f8548] == address(0)) revert IncorrectStakedPhantomTokenException();
        _0x60116e(_0x41d696);
        return false;
    }

    /// @notice Deposits phantom token (not implemented for redemption vaults)
    /// @return Never returns (always reverts)
    /// @dev Redemption vaults only support withdrawals, not deposits
    function _0x709c1d(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }

    /// @dev Converts the token amount to 18 decimals, which is accepted by Midas
    function _0x572b2f(uint256 _0x41d696, address _0x0f8548) internal view returns (uint256) {
        uint256 _0x6bc20d = 10 ** IERC20Metadata(_0x0f8548)._0x56dbe7();
        return _0x41d696 * WAD / _0x6bc20d;
    }

    /// @notice Returns whether a token is allowed as output for redemptions
    /// @param token Token address to check
    /// @return True if token is allowed
    function _0xe1e48b(address _0x0f8548) public view override returns (bool) {
        return _0x4d354c._0x355526(_0x0f8548);
    }

    /// @notice Returns all allowed output tokens
    /// @return Array of allowed token addresses
    function _0xad32fb() public view override returns (address[] memory) {
        return _0x4d354c._0xdc4536();
    }

    /// @notice Sets the allowed status for a batch of output tokens
    /// @param configs Array of MidasAllowedTokenStatus structs
    /// @dev Can only be called by the configurator
    function _0xdda108(MidasAllowedTokenStatus[] calldata _0xbbdbd1)
        external
        override
        _0x4debd9
    {
        uint256 _0x5a4f51 = _0xbbdbd1.length;

        for (uint256 i; i < _0x5a4f51; ++i) {
            MidasAllowedTokenStatus memory _0x665b71 = _0xbbdbd1[i];

            if (_0x665b71._0x5dd422) {
                _0x7afa11(_0x665b71._0x0f8548);
                _0x4d354c._0xd2198b(_0x665b71._0x0f8548);

                if (_0x665b71._0x52d883 != address(0)) {
                    _0x7afa11(_0x665b71._0x52d883);
                    _0x0bcd01[_0x665b71._0x52d883] = _0x665b71._0x0f8548;
                    _0x5f6ebb[_0x665b71._0x0f8548] = _0x665b71._0x52d883;
                }
            } else {
                _0x4d354c._0x3fe11f(_0x665b71._0x0f8548);

                address _0x52d883 = _0x5f6ebb[_0x665b71._0x0f8548];

                if (_0x52d883 != address(0)) {
                    delete _0x5f6ebb[_0x665b71._0x0f8548];
                    delete _0x0bcd01[_0x52d883];
                }
            }

            emit SetTokenAllowedStatus(_0x665b71._0x0f8548, _0x665b71._0x52d883, _0x665b71._0x5dd422);
        }
    }

    /// @notice Serialized adapter parameters
    /// @return serializedData Encoded adapter configuration
    function _0xc02d65() external view returns (bytes memory _0x0561bc) {
        _0x0561bc = abi._0x89022d(_0x730d9a, _0x88b6ca, _0xe7ba3d, _0xe56085, _0xad32fb());
    }
}