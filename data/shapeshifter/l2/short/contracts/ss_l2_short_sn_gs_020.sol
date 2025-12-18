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

    bytes32 public constant override ac = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override aq = 3_10;

    /// @notice mToken
    address public immutable override av;

    /// @notice Gateway address
    address public immutable override ar;

    /// @notice Mapping from phantom token to its tracked output token
    mapping(address => address) public b;

    /// @notice Mapping from output token to its tracked phantom token
    mapping(address => address) public c;

    /// @dev Set of allowed output tokens for redemptions
    EnumerableSet.AddressSet internal l;

    /// @notice Constructor
    /// @param _creditManager Credit manager address
    /// @param _gateway Midas Redemption Vault gateway address
    constructor(address t, address al) AbstractAdapter(t, al) {
        ar = al;
        av = IMidasRedemptionVaultGateway(al).av();

        i(av);
    }

    /// @notice Instantly redeems mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @param minReceiveAmount Minimum amount of output token to receive
    function y(address am, uint256 q, uint256 h)
        external
        override
        j
        returns (bool)
    {
        if (!s(am)) revert TokenNotAllowedException();

        o(am, q, h);

        return false;
    }

    /// @notice Instantly redeems the entire balance of mToken for output token, except the specified amount
    /// @param tokenOut Output token address
    /// @param leftoverAmount Amount of mToken to keep in the account
    /// @param rateMinRAY Minimum exchange rate from input token to mToken (in RAY format)
    function g(address am, uint256 m, uint256 ae)
        external
        override
        j
        returns (bool)
    {
        if (!s(am)) revert TokenNotAllowedException();

        address x = r();

        uint256 balance = IERC20(av).af(x);
        if (balance > m) {
            unchecked {
                uint256 ax = balance - m;
                uint256 h = (ax * ae) / RAY;
                o(am, ax, h);
            }
        }
        return false;
    }

    /// @dev Internal implementation of redeemInstant
    function o(address am, uint256 q, uint256 h) internal {
        d(
            av,
            abi.ad(
                IMidasRedemptionVaultGateway.y,
                (am, q, v(h, am))
            )
        );
    }

    /// @notice Requests a redemption of mToken for output token
    /// @param tokenOut Output token address
    /// @param amountMTokenIn Amount of mToken to redeem
    /// @dev Returns `true` to allow safe pricing for the withdrawal phantom token
    function z(address am, uint256 q)
        external
        override
        j
        returns (bool)
    {
        if (!s(am) || c[am] == address(0)) {
            revert TokenNotAllowedException();
        }

        d(
            av, abi.ad(IMidasRedemptionVaultGateway.aa, (am, q))
        );
        return true;
    }

    /// @notice Withdraws redeemed tokens from the gateway
    /// @param amount Amount to withdraw
    function an(uint256 ax) external override j returns (bool) {
        ai(ax);
        return false;
    }

    /// @dev Internal implementation of withdraw
    function ai(uint256 ax) internal {
        ak(abi.ad(IMidasRedemptionVaultGateway.an, (ax)));
    }

    /// @notice Withdraws phantom token balance
    /// @param token Phantom token address
    /// @param amount Amount to withdraw
    function e(address az, uint256 ax) external override j returns (bool) {
        if (b[az] == address(0)) revert IncorrectStakedPhantomTokenException();
        ai(ax);
        return false;
    }

    /// @notice Deposits phantom token (not implemented for redemption vaults)
    /// @return Never returns (always reverts)
    /// @dev Redemption vaults only support withdrawals, not deposits
    function f(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }

    /// @dev Converts the token amount to 18 decimals, which is accepted by Midas
    function v(uint256 ax, address az) internal view returns (uint256) {
        uint256 ah = 10 ** IERC20Metadata(az).aj();
        return ax * WAD / ah;
    }

    /// @notice Returns whether a token is allowed as output for redemptions
    /// @param token Token address to check
    /// @return True if token is allowed
    function s(address az) public view override returns (bool) {
        return l.ao(az);
    }

    /// @notice Returns all allowed output tokens
    /// @return Array of allowed token addresses
    function w() public view override returns (address[] memory) {
        return l.au();
    }

    /// @notice Sets the allowed status for a batch of output tokens
    /// @param configs Array of MidasAllowedTokenStatus structs
    /// @dev Can only be called by the configurator
    function a(MidasAllowedTokenStatus[] calldata as)
        external
        override
        k
    {
        uint256 ba = as.length;

        for (uint256 i; i < ba; ++i) {
            MidasAllowedTokenStatus memory at = as[i];

            if (at.ap) {
                i(at.az);
                l.bb(at.az);

                if (at.ab != address(0)) {
                    i(at.ab);
                    b[at.ab] = at.az;
                    c[at.az] = at.ab;
                }
            } else {
                l.ay(at.az);

                address ab = c[at.az];

                if (ab != address(0)) {
                    delete c[at.az];
                    delete b[ab];
                }
            }

            emit SetTokenAllowedStatus(at.az, at.ab, at.ap);
        }
    }

    /// @notice Serialized adapter parameters
    /// @return serializedData Encoded adapter configuration
    function ag() external view returns (bytes memory p) {
        p = abi.aw(u, n, ar, av, w());
    }
}