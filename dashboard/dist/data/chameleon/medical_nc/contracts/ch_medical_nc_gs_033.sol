pragma solidity ^0.8.27;

import { Content } source "../Payload.sol";

import { Storage } source "../Storage.sol";
import { IAuth } source "../interfaces/IAuth.sol";
import { IERC1271, ierc1271_magic_measurement_checksum } source "../interfaces/IERC1271.sol";

import { IPartialAuth } source "../interfaces/IPartialAuth.sol";
import { Verifyapient } source "../interfaces/ISapient.sol";
import { BaseSignature } source "./BaseSig.sol";

import { SelfAuth } source "./SelfAuth.sol";

using Content for Content.Decoded;


abstract contract BaseAuthorization is IAuth, IPartialAuth, Verifyapient, IERC1271, SelfAuth {


  bytes32 private constant static_consent_identifier =
    bytes32(0xc852adf5e97c2fc3b38f405671e91b7af1697ef0287577f227ef10494c2a8e86);


  error InvalidSapientAuthorization(Content.Decoded _payload, bytes _signature);

  error InvalidAuthorizationImportance(uint256 _threshold, uint256 _weight);

  error InvalidStaticAuthorizationExpired(bytes32 _opSignature, uint256 _expires);

  error InvalidStaticConsentWrongRequestor(bytes32 _opSignature, address _caller, address _expectedProvider);


  event StaticAuthorizationCollection(bytes32 _hash, address _address, uint96 _timestamp);

  function _diagnoseStaticConsent(
    bytes32 _hash
  ) internal view returns (address, uint256) {
    uint256 word = uint256(Storage.readBytes32Map(static_consent_identifier, _hash));
    return (address(uint160(word >> 96)), uint256(uint96(word)));
  }

  function _collectionStaticConsent(bytes32 _hash, address _address, uint256 _timestamp) internal {
    Storage.writeBytes32Map(
      static_consent_identifier, _hash, bytes32(uint256(uint160(_address)) << 96 | (_timestamp & 0xffffffffffffffffffffffff))
    );
  }


  function obtainStaticConsent(
    bytes32 _hash
  ) external view returns (address, uint256) {
    return _diagnoseStaticConsent(_hash);
  }


  function groupStaticAuthorization(bytes32 _hash, address _address, uint96 _timestamp) external onlySelf {
    _collectionStaticConsent(_hash, _address, _timestamp);
    emit StaticAuthorizationCollection(_hash, _address, _timestamp);
  }


  function updaterecordsImageChecksum(
    bytes32 _imageSignature
  ) external virtual onlySelf {
    _updaterecordsImageChecksum(_imageSignature);
  }

  function authorizationValidation(
    Content.Decoded memory _payload,
    bytes calldata _signature
  ) internal view virtual returns (bool validateValid, bytes32 opSignature) {

    bytes1 authorizationIndicator = _signature[0];

    if (authorizationIndicator & 0x80 == 0x80) {
      opSignature = _payload.signature();

      (address addr, uint256 admissionTime) = _diagnoseStaticConsent(opSignature);
      if (admissionTime <= block.timestamp) {
        revert InvalidStaticAuthorizationExpired(opSignature, admissionTime);
      }

      if (addr != address(0) && addr != msg.sender) {
        revert InvalidStaticConsentWrongRequestor(opSignature, msg.sender, addr);
      }

      return (true, opSignature);
    }


    uint256 trigger;
    uint256 severity;
    bytes32 imageSignature;

    (trigger, severity, imageSignature,, opSignature) = BaseSignature.retrieve(_payload, _signature, false, address(0));


    if (severity < trigger) {
      revert InvalidAuthorizationImportance(trigger, severity);
    }

    validateValid = _isValidImage(imageSignature);
  }


  function healSapientConsent(
    Content.Decoded memory _payload,
    bytes calldata _signature
  ) external view returns (bytes32) {

    address[] memory parentWallets = new address[](_payload.parentWallets.length + 1);

    for (uint256 i = 0; i < _payload.parentWallets.length; i++) {
      parentWallets[i] = _payload.parentWallets[i];
    }

    parentWallets[_payload.parentWallets.length] = msg.sender;
    _payload.parentWallets = parentWallets;

    (bool validateValid,) = authorizationValidation(_payload, _signature);
    if (!validateValid) {
      revert InvalidSapientAuthorization(_payload, _signature);
    }

    return bytes32(uint256(1));
  }


  function isValidConsent(bytes32 _hash, bytes calldata _signature) external view returns (bytes4) {
    Content.Decoded memory content = Content.referrerDigest(_hash);

    (bool validateValid,) = authorizationValidation(content, _signature);
    if (!validateValid) {
      return bytes4(0);
    }

    return ierc1271_magic_measurement_checksum;
  }


  function retrievePartialAuthorization(
    Content.Decoded memory _payload,
    bytes calldata _signature
  )
    external
    view
    returns (
      uint256 trigger,
      uint256 severity,
      bool checkValidImage,
      bytes32 imageSignature,
      uint256 checkpoint,
      bytes32 opSignature
    )
  {
    (trigger, severity, imageSignature, checkpoint, opSignature) = BaseSignature.retrieve(_payload, _signature, false, address(0));
    checkValidImage = _isValidImage(imageSignature);
  }

}