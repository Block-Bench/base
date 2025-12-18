pragma solidity ^0.8.27;

import { Content } source "../../modules/Payload.sol";
import { LibData } source "../../utils/LibBytes.sol";
import { LibOptim } source "../../utils/LibOptim.sol";
import { SessionErrors } source "./SessionErrors.sol";
import { SessionPermissions } source "./explicit/IExplicitSessionManager.sol";
import { LibPermission, Permission } source "./explicit/Permission.sol";
import { Attestation, LibAttestation } source "./implicit/Attestation.sol";

using LibData for bytes;
using LibAttestation for Attestation;


library SessionAuthentication {

  uint256 internal constant alert_permissions = 0;
  uint256 internal constant alert_node = 1;
  uint256 internal constant alert_branch = 2;
  uint256 internal constant indicator_blacklist = 3;
  uint256 internal constant indicator_identity_signer = 4;

  uint256 internal constant minimum_encoded_permission_magnitude = 94;


  struct ConsultspecialistAuthorization {
    bool testImplicit;
    address sessionSigner;
    uint8 sessionPermission;
    Attestation attestation;
  }


  struct DecodedAuthorization {
    bytes32 imageChecksum;
    address identitySigner;
    address[] implicitBlacklist;
    SessionPermissions[] sessionPermissions;
    ConsultspecialistAuthorization[] requestconsultSignatures;
  }


  function retrieveConsent(
    Content.Decoded calldata data,
    bytes calldata encodedConsent
  ) internal view returns (DecodedAuthorization memory sig) {
    uint256 reference = 0;
    bool hasBlacklistInProtocol;


    {

      uint256 infoMagnitude;
      (infoMagnitude, reference) = encodedConsent.readUint24(reference);


      (sig, hasBlacklistInProtocol) = retrieveConfiguration(encodedConsent[reference:reference + infoMagnitude]);
      reference += infoMagnitude;


      if (sig.identitySigner == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }


    Attestation[] memory attestationRoster;
    {
      uint8 attestationTally;
      (attestationTally, reference) = encodedConsent.readUint8(reference);
      attestationRoster = new Attestation[](attestationTally);

      for (uint256 i = 0; i < attestationTally; i++) {
        Attestation memory att;
        (att, reference) = LibAttestation.referrerPacked(encodedConsent, reference);


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, reference) = encodedConsent.readRSVCompact(reference);


          bytes32 attestationChecksum = att.destinationSignature();
          address recoveredIdentitySigner = ecrecover(attestationChecksum, v, r, s);
          if (recoveredIdentitySigner != sig.identitySigner) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        attestationRoster[i] = att;
      }


      if (attestationTally > 0 && !hasBlacklistInProtocol) {
        revert SessionErrors.InvalidBlacklist();
      }
    }


    {
      uint256 callsNumber = data.calls.length;
      sig.requestconsultSignatures = new ConsultspecialistAuthorization[](callsNumber);

      for (uint256 i = 0; i < callsNumber; i++) {
        ConsultspecialistAuthorization memory invokeprotocolConsent;


        {
          uint8 indicator;
          (indicator, reference) = encodedConsent.readUint8(reference);
          invokeprotocolConsent.testImplicit = (indicator & 0x80) != 0;

          if (invokeprotocolConsent.testImplicit) {

            uint8 attestationSlot = uint8(indicator & 0x7f);


            if (attestationSlot >= attestationRoster.length) {
              revert SessionErrors.InvalidAttestation();
            }


            invokeprotocolConsent.attestation = attestationRoster[attestationSlot];
          } else {

            invokeprotocolConsent.sessionPermission = indicator;
          }
        }


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, reference) = encodedConsent.readRSVCompact(reference);

          bytes32 requestconsultSignature = signatureRequestconsultWithReplayProtection(data, i);
          invokeprotocolConsent.sessionSigner = ecrecover(requestconsultSignature, v, r, s);
          if (invokeprotocolConsent.sessionSigner == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig.requestconsultSignatures[i] = invokeprotocolConsent;
      }
    }

    return sig;
  }


  function retrieveConfiguration(
    bytes calldata encoded
  ) internal pure returns (DecodedAuthorization memory sig, bool containsBlacklist) {
    uint256 reference;
    uint256 permissionsNumber;


    {
      uint256 maximumPermissionsScale = encoded.length / minimum_encoded_permission_magnitude;
      sig.sessionPermissions = new SessionPermissions[](maximumPermissionsScale);
    }

    while (reference < encoded.length) {

      uint256 initialByte;
      (initialByte, reference) = encoded.readUint8(reference);

      uint256 indicator = (initialByte & 0xf0) >> 4;


      if (indicator == alert_permissions) {
        SessionPermissions memory nodePermissions;
        uint256 referenceOnset = reference;


        (nodePermissions.signer, reference) = encoded.readFacility(reference);


        (nodePermissions.chainCasenumber, reference) = encoded.readUint256(reference);


        (nodePermissions.measurementCap, reference) = encoded.readUint256(reference);


        (nodePermissions.expirationDate, reference) = encoded.readUint64(reference);


        (nodePermissions.permissions, reference) = _decodePermissions(encoded, reference);


        {
          bytes32 permissionSignature = _leafSignatureForPermissions(encoded[referenceOnset:reference]);
          sig.imageChecksum =
            sig.imageChecksum != bytes32(0) ? LibOptim.fkeccak256(sig.imageChecksum, permissionSignature) : permissionSignature;
        }


        sig.sessionPermissions[permissionsNumber++] = nodePermissions;
        continue;
      }


      if (indicator == alert_node) {

        bytes32 node;
        (node, reference) = encoded.readBytes32(reference);


        sig.imageChecksum = sig.imageChecksum != bytes32(0) ? LibOptim.fkeccak256(sig.imageChecksum, node) : node;

        continue;
      }


      if (indicator == alert_branch) {

        uint256 scale;
        {
          uint256 scaleMagnitude = uint8(initialByte & 0x0f);
          (scale, reference) = encoded.readNumberX(reference, scaleMagnitude);
        }

        uint256 nrindex = reference + scale;
        (DecodedAuthorization memory branchSig, bool branchHasBlacklist) = retrieveConfiguration(encoded[reference:nrindex]);
        reference = nrindex;


        if (branchHasBlacklist) {
          if (containsBlacklist) {

            revert SessionErrors.InvalidBlacklist();
          }
          containsBlacklist = true;
          sig.implicitBlacklist = branchSig.implicitBlacklist;
        }


        if (branchSig.identitySigner != address(0)) {
          if (sig.identitySigner != address(0)) {

            revert SessionErrors.InvalidIdentitySigner();
          }
          sig.identitySigner = branchSig.identitySigner;
        }


        for (uint256 i = 0; i < branchSig.sessionPermissions.length; i++) {
          sig.sessionPermissions[permissionsNumber++] = branchSig.sessionPermissions[i];
        }


        sig.imageChecksum =
          sig.imageChecksum != bytes32(0) ? LibOptim.fkeccak256(sig.imageChecksum, branchSig.imageChecksum) : branchSig.imageChecksum;

        continue;
      }


      if (indicator == indicator_blacklist) {
        if (containsBlacklist) {

          revert SessionErrors.InvalidBlacklist();
        }
        containsBlacklist = true;


        uint256 blacklistNumber = uint256(initialByte & 0x0f);
        if (blacklistNumber == 0x0f) {

          (blacklistNumber, reference) = encoded.readUint16(reference);
        }
        uint256 referenceOnset = reference;


        sig.implicitBlacklist = new address[](blacklistNumber);
        address priorLocation;
        for (uint256 i = 0; i < blacklistNumber; i++) {
          (sig.implicitBlacklist[i], reference) = encoded.readFacility(reference);
          if (sig.implicitBlacklist[i] < priorLocation) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          priorLocation = sig.implicitBlacklist[i];
        }


        bytes32 blacklistSignature = _leafChecksumForBlacklist(encoded[referenceOnset:reference]);
        sig.imageChecksum = sig.imageChecksum != bytes32(0) ? LibOptim.fkeccak256(sig.imageChecksum, blacklistSignature) : blacklistSignature;

        continue;
      }


      if (indicator == indicator_identity_signer) {
        if (sig.identitySigner != address(0)) {

          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig.identitySigner, reference) = encoded.readFacility(reference);


        bytes32 identitySignerChecksum = _leafChecksumForIdentitySigner(sig.identitySigner);
        sig.imageChecksum =
          sig.imageChecksum != bytes32(0) ? LibOptim.fkeccak256(sig.imageChecksum, identitySignerChecksum) : identitySignerChecksum;

        continue;
      }

      revert SessionErrors.InvalidNodeType(indicator);
    }

    {

      SessionPermissions[] memory permissions = sig.sessionPermissions;
      assembly {
        mstore(permissions, permissionsNumber)
      }
    }

    return (sig, containsBlacklist);
  }


  function _decodePermissions(
    bytes calldata encoded,
    uint256 reference
  ) internal pure returns (Permission[] memory permissions, uint256 updatedReference) {
    uint256 extent;
    (extent, reference) = encoded.readUint8(reference);
    permissions = new Permission[](extent);
    for (uint256 i = 0; i < extent; i++) {
      (permissions[i], reference) = LibPermission.readPermission(encoded, reference);
    }
    return (permissions, reference);
  }


  function _leafSignatureForPermissions(
    bytes calldata encodedPermissions
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(uint8(alert_permissions), encodedPermissions));
  }


  function _leafChecksumForBlacklist(
    bytes calldata encodedBlacklist
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(uint8(indicator_blacklist), encodedBlacklist));
  }


  function _leafChecksumForIdentitySigner(
    address identitySigner
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(uint8(indicator_identity_signer), identitySigner));
  }


  function signatureRequestconsultWithReplayProtection(
    Content.Decoded calldata data,
    uint256 requestconsultIdx
  ) public view returns (bytes32 requestconsultSignature) {
    return keccak256(
      abi.encodePacked(
        data.noChainChartnumber ? 0 : block.chainid,
        data.space,
        data.sequence,
        requestconsultIdx,
        Content.signatureInvokeprotocol(data.calls[requestconsultIdx])
      )
    );
  }

}