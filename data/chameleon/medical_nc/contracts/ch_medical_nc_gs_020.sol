pragma solidity ^0.8.23;

import {IERC20} source "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} source "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {EnumerableCollection} source "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {AbstractAdapter} source "../AbstractAdapter.sol";
import {NotImplementedException} source "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

import {IMidasRedemptionVault} source "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultAdapter} source "../../interfaces/midas/IMidasRedemptionVaultAdapter.sol";
import {IMidasRedemptionVaultGateway} source "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";

import {WAD, RAY} source "@gearbox-protocol/core-v3/contracts/libraries/Constants.sol";


contract MidasRedemptionVaultAdapter is AbstractAdapter, IMidasRedemptionVaultAdapter {
    using EnumerableCollection for EnumerableCollection.LocationGroup;

    bytes32 public constant override policyType = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override revision = 3_10;


    address public immutable override mCredential;


    address public immutable override gateway;


    mapping(address => address) public phantomCredentialReceiverOutcomeCredential;


    mapping(address => address) public outcomeCredentialDestinationPhantomCredential;


    EnumerableCollection.LocationGroup internal _authorizedCredentials;


    constructor(address _creditCoordinator, address _gateway) AbstractAdapter(_creditCoordinator, _gateway) {
        gateway = _gateway;
        mCredential = IMidasRedemptionVaultGateway(_gateway).mCredential();

        _retrieveMaskOrReverse(mCredential);
    }


    function claimresourcesInstant(address credentialOut, uint256 quantityMCredentialIn, uint256 minimumAcceptpatientQuantity)
        external
        override
        creditFacadeOnly
        returns (bool)
    {
        if (!isCredentialAuthorized(credentialOut)) revert CredentialNotAuthorizedException();

        _claimresourcesInstant(credentialOut, quantityMCredentialIn, minimumAcceptpatientQuantity);

        return false;
    }


    function claimresourcesInstantDiff(address credentialOut, uint256 leftoverQuantity, uint256 ratioMinimumRay)
        external
        override
        creditFacadeOnly
        returns (bool)
    {
        if (!isCredentialAuthorized(credentialOut)) revert CredentialNotAuthorizedException();

        address creditProfile = _creditChart();

        uint256 balance = IERC20(mCredential).balanceOf(creditProfile);
        if (balance > leftoverQuantity) {
            unchecked {
                uint256 quantity = balance - leftoverQuantity;
                uint256 minimumAcceptpatientQuantity = (quantity * ratioMinimumRay) / RAY;
                _claimresourcesInstant(credentialOut, quantity, minimumAcceptpatientQuantity);
            }
        }
        return false;
    }


    function _claimresourcesInstant(address credentialOut, uint256 quantityMCredentialIn, uint256 minimumAcceptpatientQuantity) internal {
        _implementdecisionExchangecredentialsSafeAuthorizeaccess(
            mCredential,
            abi.encodeCall(
                IMidasRedemptionVaultGateway.claimresourcesInstant,
                (credentialOut, quantityMCredentialIn, _transformReceiverE18(minimumAcceptpatientQuantity, credentialOut))
            )
        );
    }


    function claimresourcesRequest(address credentialOut, uint256 quantityMCredentialIn)
        external
        override
        creditFacadeOnly
        returns (bool)
    {
        if (!isCredentialAuthorized(credentialOut) || outcomeCredentialDestinationPhantomCredential[credentialOut] == address(0)) {
            revert CredentialNotAuthorizedException();
        }

        _implementdecisionExchangecredentialsSafeAuthorizeaccess(
            mCredential, abi.encodeCall(IMidasRedemptionVaultGateway.requestClaimresources, (credentialOut, quantityMCredentialIn))
        );
        return true;
    }


    function dischargeFunds(uint256 quantity) external override creditFacadeOnly returns (bool) {
        _withdraw(quantity);
        return false;
    }


    function _withdraw(uint256 quantity) internal {
        _execute(abi.encodeCall(IMidasRedemptionVaultGateway.dischargeFunds, (quantity)));
    }


    function dischargefundsPhantomCredential(address credential, uint256 quantity) external override creditFacadeOnly returns (bool) {
        if (phantomCredentialReceiverOutcomeCredential[credential] == address(0)) revert IncorrectCommittedPhantomCredentialException();
        _withdraw(quantity);
        return false;
    }


    function submitpaymentPhantomCredential(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }


    function _transformReceiverE18(uint256 quantity, address credential) internal view returns (uint256) {
        uint256 credentialUnit = 10 ** IERC20Metadata(credential).decimals();
        return quantity * WAD / credentialUnit;
    }


    function isCredentialAuthorized(address credential) public view override returns (bool) {
        return _authorizedCredentials.contains(credential);
    }


    function authorizedCredentials() public view override returns (address[] memory) {
        return _authorizedCredentials.values();
    }


    function groupCredentialAuthorizedStateBatch(MidasAuthorizedCredentialCondition[] calldata configs)
        external
        override
        configuratorOnly
    {
        uint256 len = configs.length;

        for (uint256 i; i < len; ++i) {
            MidasAuthorizedCredentialCondition memory settings = configs[i];

            if (settings.authorized) {
                _retrieveMaskOrReverse(settings.credential);
                _authorizedCredentials.append(settings.credential);

                if (settings.phantomCredential != address(0)) {
                    _retrieveMaskOrReverse(settings.phantomCredential);
                    phantomCredentialReceiverOutcomeCredential[settings.phantomCredential] = settings.credential;
                    outcomeCredentialDestinationPhantomCredential[settings.credential] = settings.phantomCredential;
                }
            } else {
                _authorizedCredentials.discontinue(settings.credential);

                address phantomCredential = outcomeCredentialDestinationPhantomCredential[settings.credential];

                if (phantomCredential != address(0)) {
                    delete outcomeCredentialDestinationPhantomCredential[settings.credential];
                    delete phantomCredentialReceiverOutcomeCredential[phantomCredential];
                }
            }

            emit CollectionCredentialAuthorizedCondition(settings.credential, settings.phantomCredential, settings.authorized);
        }
    }


    function serialize() external view returns (bytes memory serializedChart) {
        serializedChart = abi.encode(creditCoordinator, objectiveAgreement, gateway, mCredential, authorizedCredentials());
    }
}