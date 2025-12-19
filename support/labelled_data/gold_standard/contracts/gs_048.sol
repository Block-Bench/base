function onSablierLockupCancel(
    uint256 streamId,
    address, /* sender */
    uint128 senderAmount,
    uint128 /* recipientAmount */
)
    external
    override
    noDelegateCall
    returns (bytes4)
{
    // Cast `msg.sender` as the Lockup NFT.
    ISablierLockupNFT msgSenderAsLockup = ISablierLockupNFT(msg.sender);
    
    // Get the Pool ID in which the stream ID is staked.
    uint256 poolId = _streamsLookup[msgSenderAsLockup][streamId].poolId;
    
    // Check: the Pool ID is not zero.
    // BUG: This reverts if NFT is in staking contract but not staked
    // Attacker can trigger this revert by sending NFT directly to contract
    if (poolId == 0) {
        revert Errors.SablierStaking_StreamNotStaked(msgSenderAsLockup, streamId);
    }
    
    // Load the storage in memory.
    address owner = _streamsLookup[msgSenderAsLockup][streamId].owner;
    uint128 streamAmountStaked = _userAccounts[owner][poolId].streamAmountStaked;
    
    // Checks and Effects: unstake the `senderAmount` for the user.
    _unstake({ poolId: poolId, unstakeAmount: senderAmount, maxAllowed: streamAmountStaked, user: owner });
    
    // Safe to use `unchecked` because `_unstake` verifies that `senderAmount` does not exceed `streamAmountStaked`.
    unchecked {
        // Effect: decrease the user's stream amount staked.
        _userAccounts[owner][poolId].streamAmountStaked = streamAmountStaked - senderAmount;
    }
    return ISablierLockupRecipient.onSablierLockupCancel.selector;
}

// BUG DETAILS:
// The revert happens when:
// 1. Stream is created from sender to recipient
// 2. Recipient receives the Lockup NFT
// 3. Recipient withdraws streamed balance
// 4. Recipient sends NFT directly to SablierStaking contract
// 5. NFT is now in contract but not staked (poolId == 0)
// 6. Sender calls cancel() on Lockup to recover unstreamed funds
// 7. Lockup notifies SablierStaking via onSablierLockupCancel hook
// 8. Hook queries _streamsLookup[lockupAddress][streamId].poolId
// 9. poolId is 0 (NFT never staked, just transferred)
// 10. Hook reverts: SablierStaking_StreamNotStaked
// 11. Cancellation transaction fails
// 12. Sender cannot cancel and recover funds
//
// IMPACT:
// - Sender's unstreamed funds are locked
// - Sender cannot recover capital
// - Funds become inaccessible until NFT is moved or staked
// - Gas wasted by sender's failed cancellation attempt