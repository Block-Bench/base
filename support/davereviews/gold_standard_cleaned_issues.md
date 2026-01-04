## Gold Standard (cleaned) metadata ↔ code validation issues (`dataset/gold_standard/cleaned`)

### Meta-audit note

- **Vulnerability confirmation is not fully possible from `cleaned/` alone** for findings where core logic is in “context” files. In `gold_standard/original`, several samples ship extra context contracts under `contracts/context/gs_XXX/`, but **`gold_standard/cleaned/contracts/context/` is empty** (no per-sample context directories).
- **Sanitization correctness (confirmed)**: for all 34 samples, `cleaned/contracts/gs_XXX.sol` matches `original/contracts/gs_XXX.sol` after removing only:
  - the vulnerability header block comment,
  - `// ^^^ VULNERABLE LINE ^^^` marker lines,
  - `@audit-issue ...` lines,
  - plus harmless whitespace normalization (blank lines / trailing spaces).
  - This indicates the **underlying vulnerable code is preserved** in `cleaned/`, and the remaining review is primarily about **metadata correctness + missing context packaging**.

### Dataset-level issues

- **Missing per-sample context bundle (blocking for full semantic verification):**
  - `dataset/gold_standard/original/contracts/context/` contains context subdirectories for **16 samples that also exist in `cleaned/`**:
    - `gs_008`, `gs_011`, `gs_012`, `gs_014`, `gs_015`, `gs_016`, `gs_018`, `gs_019`, `gs_021`, `gs_022`, `gs_027`, `gs_028`, `gs_030`, `gs_031`, `gs_032`, `gs_033`
  - `dataset/gold_standard/cleaned/contracts/context/` contains **0** subdirectories/files.
  - **Impact**: for findings that rely on Base/manager/auth/session helper logic, the cleaned variant does not carry enough code to independently validate the metadata claims.

- **`vulnerable_lines` is always empty: 34/34** cleaned metadata files set `vulnerable_lines: []` (while `original/metadata/gs_*.json` often provides concrete line lists), so line-level localization cannot be validated/scored from cleaned metadata.

### Metadata identifier mismatches (definite correctness issues)

- `gs_001`: `vulnerable_contract` is `GovernanceHYBR` but contract file defines ['GrowthHYBR', 'uint256'] (no `GovernanceHYBR`).
- `gs_004`: `vulnerable_contract` is `GovernanceHYBR` but contract file defines ['GrowthHYBR', 'uint256'] (no `GovernanceHYBR`).
- `gs_008`: `vulnerable_contract` is `GovernanceHYBR` but contract file defines ['GrowthHYBR', 'uint256'] (no `GovernanceHYBR`).
- `gs_029`: `vulnerable_function` is `executeSessionCalls` but it is not declared in the contract file. Declared functions include (sample): ['_execute', 'execute', 'selfExecute'].

### Missing relative imports by contract (blocking for full semantic verification)

- `gs_001`: `./interfaces/IVotingEscrow.sol`, `./interfaces/IVoter.sol`, `./interfaces/IBribe.sol`, `./interfaces/IRewardsDistributor.sol`, `./interfaces/IGaugeManager.sol`, `./interfaces/ISwapper.sol`, `./libraries/HybraTimeLibrary.sol`
- `gs_002`: `./interfaces/ICLFactory.sol`, `./interfaces/fees/IFeeModule.sol`, `./interfaces/IGaugeManager.sol`, `./interfaces/IFactoryRegistry.sol`, `./CLPool.sol`
- `gs_003`: `./interfaces/IPair.sol`, `./interfaces/IBribe.sol`, `./libraries/Math.sol`, `./libraries/HybraTimeLibrary.sol`, `./interfaces/IRHYBR.sol`
- `gs_004`: `./interfaces/IVotingEscrow.sol`, `./interfaces/IVoter.sol`, `./interfaces/IBribe.sol`, `./interfaces/IRewardsDistributor.sol`, `./interfaces/IGaugeManager.sol`, `./interfaces/ISwapper.sol`, `./libraries/HybraTimeLibrary.sol`
- `gs_005`: `./libraries/Math.sol`, `./interfaces/IBribe.sol`, `./interfaces/IERC20.sol`, `./interfaces/IPairInfo.sol`, `./interfaces/IPairFactory.sol`, `./interfaces/IVotingEscrow.sol`, `./interfaces/IGaugeManager.sol`, `./interfaces/IPermissionsRegistry.sol`, `./interfaces/ITokenHandler.sol`, `./libraries/HybraTimeLibrary.sol`
- `gs_006`: `../interfaces/IGaugeFactoryCL.sol`, `../interfaces/IGaugeManager.sol`, `./interface/ICLPool.sol`, `./interface/ICLFactory.sol`, `./interface/INonfungiblePositionManager.sol`, `../interfaces/IBribe.sol`, `../interfaces/IRHYBR.sol`, `../libraries/HybraTimeLibrary.sol`, `./libraries/FullMath.sol`, `./libraries/FixedPoint128.sol`, `../interfaces/IRHYBR.sol`
- `gs_007`: `../interfaces/IGaugeFactoryCL.sol`, `../interfaces/IGaugeManager.sol`, `./interface/ICLPool.sol`, `./interface/ICLFactory.sol`, `./interface/INonfungiblePositionManager.sol`, `../interfaces/IBribe.sol`, `../interfaces/IRHYBR.sol`, `../libraries/HybraTimeLibrary.sol`, `./libraries/FullMath.sol`, `./libraries/FixedPoint128.sol`, `../interfaces/IRHYBR.sol`
- `gs_008`: `./interfaces/IVotingEscrow.sol`, `./interfaces/IVoter.sol`, `./interfaces/IBribe.sol`, `./interfaces/IRewardsDistributor.sol`, `./interfaces/IGaugeManager.sol`, `./interfaces/ISwapper.sol`, `./libraries/HybraTimeLibrary.sol`
- `gs_009`: `./interfaces/IERC20.sol`, `./interfaces/IHybra.sol`, `./interfaces/IHybraVotes.sol`, `./interfaces/IVeArtProxy.sol`, `./interfaces/IVotingEscrow.sol`, `./interfaces/IVoter.sol`, `./libraries/HybraTimeLibrary.sol`, `./libraries/VotingDelegationLib.sol`, `./libraries/VotingBalanceLogic.sol`
- `gs_010`: `../interfaces/ILockToGovernBase.sol`, `../interfaces/ILockManager.sol`
- `gs_011`: `./interfaces/ILockManager.sol`, `./base/LockToGovernBase.sol`, `./interfaces/ILockToVote.sol`, `./base/MajorityVotingBase.sol`, `./interfaces/ILockToGovernBase.sol`
- `gs_012`: `./base/LockManagerBase.sol`, `./interfaces/ILockManager.sol`, `./interfaces/ILockManager.sol`
- `gs_013`: `./base/LockManagerBase.sol`, `./interfaces/ILockManager.sol`, `./interfaces/ILockManager.sol`
- `gs_014`: `../interfaces/ILockManager.sol`, `../interfaces/ILockToGovernBase.sol`, `../interfaces/ILockToVote.sol`, `../interfaces/IMajorityVoting.sol`
- `gs_015`: `./interfaces/ILockManager.sol`, `./base/LockToGovernBase.sol`, `./interfaces/ILockToVote.sol`, `./base/MajorityVotingBase.sol`, `./interfaces/ILockToGovernBase.sol`
- `gs_016`: `../interfaces/ILockToGovernBase.sol`, `../interfaces/ILockManager.sol`
- `gs_017`: `./interfaces/ILockManager.sol`, `./base/LockToGovernBase.sol`, `./interfaces/ILockToVote.sol`, `./base/MajorityVotingBase.sol`, `./interfaces/ILockToGovernBase.sol`
- `gs_018`: `../../integrations/midas/IMidasRedemptionVault.sol`, `../../interfaces/midas/IMidasRedemptionVaultGateway.sol`
- `gs_019`: `../AbstractAdapter.sol`, `../../integrations/midas/IMidasRedemptionVault.sol`, `../../interfaces/midas/IMidasRedemptionVaultAdapter.sol`, `../../interfaces/midas/IMidasRedemptionVaultGateway.sol`
- `gs_020`: `./base/BaseKEMHook.sol`, `./interfaces/IKEMHook.sol`, `./libraries/HookDataDecoder.sol`
- `gs_021`: `./base/BaseKEMHook.sol`, `./interfaces/IKEMHook.sol`, `./libraries/HookDataDecoder.sol`
- `gs_022`: `./interfaces/ILiquidityBuffer.sol`, `./interfaces/IPositionManager.sol`, `../interfaces/IStaking.sol`, `../interfaces/IPauser.sol`, `../interfaces/ProtocolEvents.sol`
- `gs_023`: `./interfaces/ILiquidityBuffer.sol`, `./interfaces/IPositionManager.sol`, `../interfaces/IStaking.sol`, `../interfaces/IPauser.sol`, `../interfaces/ProtocolEvents.sol`
- `gs_024`: `./interfaces/ProtocolEvents.sol`, `./interfaces/IDepositContract.sol`, `./interfaces/IMETH.sol`, `./interfaces/IOracle.sol`, `./interfaces/IPauser.sol`, `./interfaces/IStaking.sol`, `./interfaces/IUnstakeRequestsManager.sol`, `./liquidityBuffer/interfaces/ILiquidityBuffer.sol`
- `gs_025`: `./interfaces/IPositionManager.sol`, `./interfaces/IWETH.sol`, `../liquidityBuffer/interfaces/ILiquidityBuffer.sol`
- `gs_026`: `./interfaces/ProtocolEvents.sol`, `./interfaces/IDepositContract.sol`, `./interfaces/IMETH.sol`, `./interfaces/IOracle.sol`, `./interfaces/IPauser.sol`, `./interfaces/IStaking.sol`, `./interfaces/IUnstakeRequestsManager.sol`, `./liquidityBuffer/interfaces/ILiquidityBuffer.sol`
- `gs_027`: `./interfaces/ProtocolEvents.sol`, `./interfaces/IDepositContract.sol`, `./interfaces/IMETH.sol`, `./interfaces/IOracle.sol`, `./interfaces/IPauser.sol`, `./interfaces/IStaking.sol`, `./interfaces/IUnstakeRequestsManager.sol`, `./liquidityBuffer/interfaces/ILiquidityBuffer.sol`
- `gs_028`: `../../utils/LibBytes.sol`, `../../utils/LibOptim.sol`, `../Payload.sol`, `../interfaces/ICheckpointer.sol`, `../interfaces/IERC1271.sol`, `../interfaces/ISapient.sol`
- `gs_029`: `../utils/LibOptim.sol`, `./Nonce.sol`, `./Payload.sol`, `./ReentrancyGuard.sol`, `./auth/BaseAuth.sol`, `./interfaces/IDelegatedExtension.sol`
- `gs_030`: `../../modules/Payload.sol`, `../../utils/LibBytes.sol`, `../../utils/LibOptim.sol`, `./SessionErrors.sol`, `./explicit/IExplicitSessionManager.sol`, `./explicit/Permission.sol`, `./implicit/Attestation.sol`
- `gs_031`: `./Calls.sol`, `./ReentrancyGuard.sol`, `./interfaces/IAccount.sol`, `./interfaces/IERC1271.sol`, `./interfaces/IEntryPoint.sol`
- `gs_032`: `../Payload.sol`, `../Storage.sol`, `../interfaces/IAuth.sol`, `../interfaces/IERC1271.sol`, `../interfaces/IPartialAuth.sol`, `../interfaces/ISapient.sol`, `./BaseSig.sol`, `./SelfAuth.sol`
- `gs_033`: `./Wallet.sol`
- `gs_034`: `../../external/IV2Pool.sol`, `../../external/IV2Router.sol`, `../../interfaces/extensions/v2/IV2LockerFactory.sol`, `../../interfaces/extensions/v2/IV2Locker.sol`, `../../interfaces/ILocker.sol`, `../../Locker.sol`

### Audit artifacts (for reproduction)

- Raw structural audit JSON: `support/davereviews/_tmp_gs_cleaned_meta_code_audit.json`
- Original→cleaned equivalence check (normalized): `support/davereviews/_tmp_gs_cleaned_transform_diff_check_v2.json`
