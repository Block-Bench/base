function _useUnorderedNonce(uint256 nonce) internal {
    if (nonce == 0) return;  // Zero nonce special case
    
    uint256 wordPos = nonce >> 8;
    uint256 bitPos = uint8(nonce);
    uint256 bit = 1 << bitPos;
    uint256 flipped = nonces[wordPos] ^= bit;
    
    if (flipped & bit == 0) revert NonceAlreadyUsed(nonce);  // Already used
    emit UseNonce(nonce);
}