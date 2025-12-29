/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ contract BasicBridge {
/*LN-5*/     // Validator addresses
/*LN-6*/     address[] public validators;
/*LN-7*/     mapping(address => bool) public isValidator;
/*LN-8*/ 
/*LN-9*/     uint256 public requiredSignatures = 5; // Need 5 out of 9
/*LN-10*/     uint256 public validatorCount;
/*LN-11*/ 
/*LN-12*/     // Track processed withdrawals to prevent replay
/*LN-13*/     mapping(uint256 => bool) public processedWithdrawals;
/*LN-14*/ 
/*LN-15*/     // Supported tokens
/*LN-16*/     mapping(address => bool) public supportedTokens;
/*LN-17*/ 
/*LN-18*/     event WithdrawalProcessed(
/*LN-19*/         uint256 indexed withdrawalId,
/*LN-20*/         address indexed user,
/*LN-21*/         address indexed token,
/*LN-22*/         uint256 amount
/*LN-23*/     );
/*LN-24*/ 
/*LN-25*/     constructor(address[] memory _validators) {
/*LN-26*/         require(
/*LN-27*/             _validators.length >= requiredSignatures,
/*LN-28*/             "Not enough validators"
/*LN-29*/         );
/*LN-30*/ 
/*LN-31*/         for (uint256 i = 0; i < _validators.length; i++) {
/*LN-32*/             address validator = _validators[i];
/*LN-33*/             require(validator != address(0), "Invalid validator");
/*LN-34*/             require(!isValidator[validator], "Duplicate validator");
/*LN-35*/ 
/*LN-36*/             validators.push(validator);
/*LN-37*/             isValidator[validator] = true;
/*LN-38*/         }
/*LN-39*/ 
/*LN-40*/         validatorCount = _validators.length;
/*LN-41*/     }
/*LN-42*/ 
/*LN-43*/     function withdrawERC20For(
/*LN-44*/         uint256 _withdrawalId,
/*LN-45*/         address _user,
/*LN-46*/         address _token,
/*LN-47*/         uint256 _amount,
/*LN-48*/         bytes memory _signatures
/*LN-49*/     ) external {
/*LN-50*/         // Check if already processed
/*LN-51*/         require(!processedWithdrawals[_withdrawalId], "Already processed");
/*LN-52*/ 
/*LN-53*/         // Check if token is supported
/*LN-54*/         require(supportedTokens[_token], "Token not supported");
/*LN-55*/ 
/*LN-56*/         // Verify signatures
/*LN-57*/ 
/*LN-58*/         require(
/*LN-59*/             _verifySignatures(
/*LN-60*/                 _withdrawalId,
/*LN-61*/                 _user,
/*LN-62*/                 _token,
/*LN-63*/                 _amount,
/*LN-64*/                 _signatures
/*LN-65*/             ),
/*LN-66*/             "Invalid signatures"
/*LN-67*/         );
/*LN-68*/ 
/*LN-69*/         // Mark as processed
/*LN-70*/         processedWithdrawals[_withdrawalId] = true;
/*LN-71*/ 
/*LN-72*/         // Transfer tokens
/*LN-73*/         // In reality, this would transfer from bridge reserves
/*LN-74*/         // IERC20(_token).transfer(_user, _amount);
/*LN-75*/ 
/*LN-76*/         emit WithdrawalProcessed(_withdrawalId, _user, _token, _amount);
/*LN-77*/     }
/*LN-78*/ 
/*LN-79*/     function _verifySignatures(
/*LN-80*/         uint256 _withdrawalId,
/*LN-81*/         address _user,
/*LN-82*/         address _token,
/*LN-83*/         uint256 _amount,
/*LN-84*/         bytes memory _signatures
/*LN-85*/     ) internal view returns (bool) {
/*LN-86*/         require(_signatures.length % 65 == 0, "Invalid signature length");
/*LN-87*/ 
/*LN-88*/         uint256 signatureCount = _signatures.length / 65;
/*LN-89*/         require(signatureCount >= requiredSignatures, "Not enough signatures");
/*LN-90*/ 
/*LN-91*/         // Reconstruct the message hash
/*LN-92*/         bytes32 messageHash = keccak256(
/*LN-93*/             abi.encodePacked(_withdrawalId, _user, _token, _amount)
/*LN-94*/         );
/*LN-95*/         bytes32 ethSignedMessageHash = keccak256(
/*LN-96*/             abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
/*LN-97*/         );
/*LN-98*/ 
/*LN-99*/         address[] memory signers = new address[](signatureCount);
/*LN-100*/ 
/*LN-101*/         // Extract and verify each signature
/*LN-102*/         for (uint256 i = 0; i < signatureCount; i++) {
/*LN-103*/             bytes memory signature = _extractSignature(_signatures, i);
/*LN-104*/             address signer = _recoverSigner(ethSignedMessageHash, signature);
/*LN-105*/ 
/*LN-106*/             // Check if signer is a validator
/*LN-107*/             require(isValidator[signer], "Invalid signer");
/*LN-108*/ 
/*LN-109*/             // Check for duplicate signers
/*LN-110*/             for (uint256 j = 0; j < i; j++) {
/*LN-111*/                 require(signers[j] != signer, "Duplicate signer");
/*LN-112*/             }
/*LN-113*/ 
/*LN-114*/             signers[i] = signer;
/*LN-115*/         }
/*LN-116*/ 
/*LN-117*/         // All checks passed
/*LN-118*/         return true;
/*LN-119*/     }
/*LN-120*/ 
/*LN-121*/     /**
/*LN-122*/      * @notice Extract a single signature from concatenated signatures
/*LN-123*/      */
/*LN-124*/     function _extractSignature(
/*LN-125*/         bytes memory _signatures,
/*LN-126*/         uint256 _index
/*LN-127*/     ) internal pure returns (bytes memory) {
/*LN-128*/         bytes memory signature = new bytes(65);
/*LN-129*/         uint256 offset = _index * 65;
/*LN-130*/ 
/*LN-131*/         for (uint256 i = 0; i < 65; i++) {
/*LN-132*/             signature[i] = _signatures[offset + i];
/*LN-133*/         }
/*LN-134*/ 
/*LN-135*/         return signature;
/*LN-136*/     }
/*LN-137*/ 
/*LN-138*/     /**
/*LN-139*/      * @notice Recover signer from signature
/*LN-140*/      */
/*LN-141*/     function _recoverSigner(
/*LN-142*/         bytes32 _hash,
/*LN-143*/         bytes memory _signature
/*LN-144*/     ) internal pure returns (address) {
/*LN-145*/         require(_signature.length == 65, "Invalid signature length");
/*LN-146*/ 
/*LN-147*/         bytes32 r;
/*LN-148*/         bytes32 s;
/*LN-149*/         uint8 v;
/*LN-150*/ 
/*LN-151*/         assembly {
/*LN-152*/             r := mload(add(_signature, 32))
/*LN-153*/             s := mload(add(_signature, 64))
/*LN-154*/             v := byte(0, mload(add(_signature, 96)))
/*LN-155*/         }
/*LN-156*/ 
/*LN-157*/         if (v < 27) {
/*LN-158*/             v += 27;
/*LN-159*/         }
/*LN-160*/ 
/*LN-161*/         require(v == 27 || v == 28, "Invalid signature v value");
/*LN-162*/ 
/*LN-163*/         return ecrecover(_hash, v, r, s);
/*LN-164*/     }
/*LN-165*/ 
/*LN-166*/     /**
/*LN-167*/      * @notice Add supported token (admin function)
/*LN-168*/      */
/*LN-169*/     function addSupportedToken(address _token) external {
/*LN-170*/         supportedTokens[_token] = true;
/*LN-171*/     }
/*LN-172*/ }
/*LN-173*/ 
/*LN-174*/ 