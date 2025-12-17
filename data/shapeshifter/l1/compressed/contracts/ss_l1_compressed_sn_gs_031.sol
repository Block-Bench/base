pragma solidity ^0.8.27;
import { Payload } from "../../modules/Payload.sol";
import { LibBytes } from "../../utils/LibBytes.sol";
import { LibOptim } from "../../utils/LibOptim.sol";
import { SessionErrors } from "./SessionErrors.sol";
import { SessionPermissions } from "./explicit/IExplicitSessionManager.sol";
import { LibPermission, Permission } from "./explicit/Permission.sol";
import { Attestation, LibAttestation } from "./implicit/Attestation.sol";
using LibBytes for bytes;
using LibAttestation for Attestation;
library SessionSig {
uint256 internal constant FLAG_PERMISSIONS = 0;
uint256 internal constant FLAG_NODE = 1;
uint256 internal constant FLAG_BRANCH = 2;
uint256 internal constant FLAG_BLACKLIST = 3;
uint256 internal constant FLAG_IDENTITY_SIGNER = 4;
uint256 internal constant MIN_ENCODED_PERMISSION_SIZE = 94;
struct CallSignature {
bool isImplicit;
address sessionSigner;
uint8 sessionPermission;
Attestation attestation;
}
struct DecodedSignature {
bytes32 imageHash;
address identitySigner;
address[] implicitBlacklist;
SessionPermissions[] sessionPermissions;
CallSignature[] callSignatures;
}
function recoverSignature(
Payload.Decoded calldata payload,
bytes calldata encodedSignature
) internal view returns (DecodedSignature memory sig) {
uint256 pointer = 0;
bool hasBlacklistInConfig;
{
uint256 dataSize;
(dataSize, pointer) = encodedSignature.readUint24(pointer);
(sig, hasBlacklistInConfig) = recoverConfiguration(encodedSignature[pointer:pointer + dataSize]);
pointer += dataSize;
if (sig.identitySigner == address(0)) {
revert SessionErrors.InvalidIdentitySigner();
}
}
Attestation[] memory attestationList;
{
uint8 attestationCount;
(attestationCount, pointer) = encodedSignature.readUint8(pointer);
attestationList = new Attestation[](attestationCount);
for (uint256 i = 0; i < attestationCount; i++) {
Attestation memory att;
(att, pointer) = LibAttestation.fromPacked(encodedSignature, pointer);
{
bytes32 r;
bytes32 s;
uint8 v;
(r, s, v, pointer) = encodedSignature.readRSVCompact(pointer);
bytes32 attestationHash = att.toHash();
address recoveredIdentitySigner = ecrecover(attestationHash, v, r, s);
if (recoveredIdentitySigner != sig.identitySigner) {
revert SessionErrors.InvalidIdentitySigner();
}
}
attestationList[i] = att;
}
if (attestationCount > 0 && !hasBlacklistInConfig) {
revert SessionErrors.InvalidBlacklist();
}
}
{
uint256 callsCount = payload.calls.length;
sig.callSignatures = new CallSignature[](callsCount);
for (uint256 i = 0; i < callsCount; i++) {
CallSignature memory callSignature;
{
uint8 flag;
(flag, pointer) = encodedSignature.readUint8(pointer);
callSignature.isImplicit = (flag & 0x80) != 0;
if (callSignature.isImplicit) {
uint8 attestationIndex = uint8(flag & 0x7f);
if (attestationIndex >= attestationList.length) {
revert SessionErrors.InvalidAttestation();
}
callSignature.attestation = attestationList[attestationIndex];
} else {
callSignature.sessionPermission = flag;
}
}
{
bytes32 r;
bytes32 s;
uint8 v;
(r, s, v, pointer) = encodedSignature.readRSVCompact(pointer);
bytes32 callHash = hashCallWithReplayProtection(payload, i);
callSignature.sessionSigner = ecrecover(callHash, v, r, s);
if (callSignature.sessionSigner == address(0)) {
revert SessionErrors.InvalidSessionSigner(address(0));
}
}
sig.callSignatures[i] = callSignature;
}
}
return sig;
}
function recoverConfiguration(
bytes calldata encoded
) internal pure returns (DecodedSignature memory sig, bool hasBlacklist) {
uint256 pointer;
uint256 permissionsCount;
{
uint256 maxPermissionsSize = encoded.length / MIN_ENCODED_PERMISSION_SIZE;
sig.sessionPermissions = new SessionPermissions[](maxPermissionsSize);
}
while (pointer < encoded.length) {
uint256 firstByte;
(firstByte, pointer) = encoded.readUint8(pointer);
uint256 flag = (firstByte & 0xf0) >> 4;
if (flag == FLAG_PERMISSIONS) {
SessionPermissions memory nodePermissions;
uint256 pointerStart = pointer;
(nodePermissions.signer, pointer) = encoded.readAddress(pointer);
(nodePermissions.chainId, pointer) = encoded.readUint256(pointer);
(nodePermissions.valueLimit, pointer) = encoded.readUint256(pointer);
(nodePermissions.deadline, pointer) = encoded.readUint64(pointer);
(nodePermissions.permissions, pointer) = _decodePermissions(encoded, pointer);
{
bytes32 permissionHash = _leafHashForPermissions(encoded[pointerStart:pointer]);
sig.imageHash =
sig.imageHash != bytes32(0) ? LibOptim.fkeccak256(sig.imageHash, permissionHash) : permissionHash;
}
sig.sessionPermissions[permissionsCount++] = nodePermissions;
continue;
}
if (flag == FLAG_NODE) {
bytes32 node;
(node, pointer) = encoded.readBytes32(pointer);
sig.imageHash = sig.imageHash != bytes32(0) ? LibOptim.fkeccak256(sig.imageHash, node) : node;
continue;
}
if (flag == FLAG_BRANCH) {
uint256 size;
{
uint256 sizeSize = uint8(firstByte & 0x0f);
(size, pointer) = encoded.readUintX(pointer, sizeSize);
}
uint256 nrindex = pointer + size;
(DecodedSignature memory branchSig, bool branchHasBlacklist) = recoverConfiguration(encoded[pointer:nrindex]);
pointer = nrindex;
if (branchHasBlacklist) {
if (hasBlacklist) {
revert SessionErrors.InvalidBlacklist();
}
hasBlacklist = true;
sig.implicitBlacklist = branchSig.implicitBlacklist;
}
if (branchSig.identitySigner != address(0)) {
if (sig.identitySigner != address(0)) {
revert SessionErrors.InvalidIdentitySigner();
}
sig.identitySigner = branchSig.identitySigner;
}
for (uint256 i = 0; i < branchSig.sessionPermissions.length; i++) {
sig.sessionPermissions[permissionsCount++] = branchSig.sessionPermissions[i];
}
sig.imageHash =
sig.imageHash != bytes32(0) ? LibOptim.fkeccak256(sig.imageHash, branchSig.imageHash) : branchSig.imageHash;
continue;
}
if (flag == FLAG_BLACKLIST) {
if (hasBlacklist) {
revert SessionErrors.InvalidBlacklist();
}
hasBlacklist = true;
uint256 blacklistCount = uint256(firstByte & 0x0f);
if (blacklistCount == 0x0f) {
(blacklistCount, pointer) = encoded.readUint16(pointer);
}
uint256 pointerStart = pointer;
sig.implicitBlacklist = new address[](blacklistCount);
address previousAddress;
for (uint256 i = 0; i < blacklistCount; i++) {
(sig.implicitBlacklist[i], pointer) = encoded.readAddress(pointer);
if (sig.implicitBlacklist[i] < previousAddress) {
revert SessionErrors.InvalidBlacklistUnsorted();
}
previousAddress = sig.implicitBlacklist[i];
}
bytes32 blacklistHash = _leafHashForBlacklist(encoded[pointerStart:pointer]);
sig.imageHash = sig.imageHash != bytes32(0) ? LibOptim.fkeccak256(sig.imageHash, blacklistHash) : blacklistHash;
continue;
}
if (flag == FLAG_IDENTITY_SIGNER) {
if (sig.identitySigner != address(0)) {
revert SessionErrors.InvalidIdentitySigner();
}
(sig.identitySigner, pointer) = encoded.readAddress(pointer);
bytes32 identitySignerHash = _leafHashForIdentitySigner(sig.identitySigner);
sig.imageHash =
sig.imageHash != bytes32(0) ? LibOptim.fkeccak256(sig.imageHash, identitySignerHash) : identitySignerHash;
continue;
}
revert SessionErrors.InvalidNodeType(flag);
}
{
SessionPermissions[] memory permissions = sig.sessionPermissions;
assembly {
mstore(permissions, permissionsCount)
}
}
return (sig, hasBlacklist);
}
function _decodePermissions(
bytes calldata encoded,
uint256 pointer
) internal pure returns (Permission[] memory permissions, uint256 newPointer) {
uint256 length;
(length, pointer) = encoded.readUint8(pointer);
permissions = new Permission[](length);
for (uint256 i = 0; i < length; i++) {
(permissions[i], pointer) = LibPermission.readPermission(encoded, pointer);
}
return (permissions, pointer);
}
function _leafHashForPermissions(
bytes calldata encodedPermissions
) internal pure returns (bytes32) {
return keccak256(abi.encodePacked(uint8(FLAG_PERMISSIONS), encodedPermissions));
}
function _leafHashForBlacklist(
bytes calldata encodedBlacklist
) internal pure returns (bytes32) {
return keccak256(abi.encodePacked(uint8(FLAG_BLACKLIST), encodedBlacklist));
}
function _leafHashForIdentitySigner(
address identitySigner
) internal pure returns (bytes32) {
return keccak256(abi.encodePacked(uint8(FLAG_IDENTITY_SIGNER), identitySigner));
}
function hashCallWithReplayProtection(
Payload.Decoded calldata payload,
uint256 callIdx
) public view returns (bytes32 callHash) {
return keccak256(
abi.encodePacked(
payload.noChainId ? 0 : block.chainid,
payload.space,
payload.nonce,
callIdx,
Payload.hashCall(payload.calls[callIdx])
)
);
}
}