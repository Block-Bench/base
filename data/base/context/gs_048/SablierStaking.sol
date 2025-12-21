// STREAM CANCELLATION FLOW:
// 1. Sender calls: lockup.cancel(streamId)
// 2. Lockup contract validates sender authorization
// 3. Lockup contract calls: ISablierLockupRecipient(nftOwner).onSablierLockupCancel(...)
// 4. If nftOwner == stakingContract, this contract's hook is called
// 5. Hook tries to unstake: poolId = _streamsLookup[lockup][streamId].poolId
// 6. If poolId == 0, hook reverts
// 7. Sender's cancellation transaction fails
// 8. Sender cannot recover funds
//
// ATTACK SCENARIO:
// Day 1: Alice sends 1,000,000 USDC to Bob over 100 days via Lockup
// Day 1: Bob receives NFT
// Day 30: Alice wants to cancel and recover 700,000 USDC
// Day 30 (same block): Bob sees Alice's pending tx
// Day 30 (Bob front-runs): Bob withdraws streamed USDC and sends NFT directly to SablierStaking
// Day 30 (continued): Alice's cancel tx is executed
// Day 30 (result): Cancel hook reverts (poolId == 0)
// Day 30+ (impact): Alice's 700,000 USDC is locked forever
// Day 30+ (continued): Alice cannot cancel, NFT is stuck in SablierStaking

// Why NFT can be sent with poolId == 0:
// 1. onERC721Received expects encoded data with poolId
// 2. If data is empty or invalid, no _streamsLookup entry is created
// 3. If onERC721Received reverts, NFT still arrives (if sent via safeTransferFrom)
// 4. Contract becomes the NFT owner but poolId is never set
// 5. Hash of _streamsLookup[lockup][streamId] is default (0)
// 
// LIKELIHOOD:
// High - Recipient has both motive (prevent sender cancellation) and ability (control NFT)
// Especially valuable if remaining stream has high value