# Smart Contract Theme Generation Instructions

## Overview

You are tasked with creating a **Medical/Healthcare** themed mapping for smart contract identifiers. These mappings will be used to transform blockchain/DeFi smart contracts into medical-domain equivalents for research purposes.

## Your Task

For each identifier category below, provide contextually appropriate **medical/healthcare** equivalents. The mappings should:

1. **Be semantically coherent** - A `withdraw` function should map to something like `dischargeFunds` or `releasePayment`, not random medical terms
2. **Preserve the functional meaning** - The medical term should convey the same action/concept
3. **Sound natural** - As if a healthcare system was actually built on blockchain
4. **Be consistent** - Related terms should use related medical concepts

## Medical Domain Context

Think of these contracts as if they were:
- Hospital patient management systems
- Healthcare insurance claim processors
- Pharmaceutical supply chain trackers
- Medical records management systems
- Clinical trial data systems
- Healthcare payment/billing systems
- Lab result tracking systems
- Prescription management systems

---

## CRITICAL: Reserved Keywords - DO NOT MAP THESE

The following are Solidity built-ins and MUST remain unchanged:

### Built-in Properties (NEVER change)
```
.length, .balance, .value, .gas, .data, .sig
.sender, .origin, .timestamp, .number, .difficulty
.transfer, .send, .call, .delegatecall, .staticcall
.push, .pop, .selector, .address, .codehash
```

### Built-in Types & Keywords (NEVER change)
```
address, uint, uint256, uint8, uint16, uint32, uint64, uint128, uint192, uint208
int, int256, bool, string, bytes, bytes4, bytes32
mapping, struct, enum, event, modifier, function, contract, library, interface
public, private, internal, external, view, pure, payable, constant, immutable
memory, storage, calldata, indexed
require, assert, revert, return, returns, throw
if, else, for, while, do, break, continue
msg, block, tx, this, super, now, abi
true, false, wei, gwei, ether, finney, szabo
constructor, fallback, receive, virtual, override, abstract
```

### Standard Library Names (preserve as-is)
```
SafeMath (and its methods: add, sub, mul, div, mod)
ERC20, ERC721, ERC1155, ERC20Basic, ERC4337
IERC20, IERC721, IERC777, IERC1820Registry
Ownable, Pausable, ReentrancyGuard
```

### Single-letter and short variables (skip these)
```
a, b, c, i, j, k, n, x, y, z, to, id
```

---

## OUTPUT FORMAT

For each identifier, provide your mapping in this exact format:
```
original -> medical_equivalent
```

Only provide mappings for identifiers you are changing. Skip any you want to keep as-is.

---

## CATEGORY 1: Contract Names (94 unique)

These are the main contract/class names. Map them to medical system/entity names.

Think: Hospital departments, medical record systems, insurance entities, pharmacy systems, etc.

```
TokenVault -> [YOUR MAPPING - e.g., MedicalRecordsVault]
CrowdFundBasic -> [YOUR MAPPING]
CrowdFundPull -> [YOUR MAPPING]
CrowdFundBatched -> [YOUR MAPPING]
TokenExchange -> [YOUR MAPPING]
BasicToken -> [YOUR MAPPING]
StandardToken -> [YOUR MAPPING]
PausableToken -> [YOUR MAPPING]
BecToken -> [YOUR MAPPING]
SmartBillions -> [YOUR MAPPING]
theRun -> [YOUR MAPPING]
VaultOperator -> [YOUR MAPPING]
Ledger -> [YOUR MAPPING]
OpenAccess -> [YOUR MAPPING]
Alice -> [YOUR MAPPING]
FibonacciBalance -> [YOUR MAPPING]
FibonacciLib -> [YOUR MAPPING]
Wallet -> [YOUR MAPPING]
Map -> [YOUR MAPPING]
MyContract -> [YOUR MAPPING]
Phishable -> [YOUR MAPPING]
Proxy -> [YOUR MAPPING]
SimpleDestruct -> [YOUR MAPPING]
PERSONAL_BANK -> [YOUR MAPPING]
PrivateBank -> [YOUR MAPPING]
ACCURAL_DEPOSIT -> [YOUR MAPPING]
PRIVATE_ETH_CELL -> [YOUR MAPPING]
LogFile -> [YOUR MAPPING]
Log -> [YOUR MAPPING]
EtherStore -> [YOUR MAPPING]
EtherBank -> [YOUR MAPPING]
CommunityVault -> [YOUR MAPPING]
SimpleVault -> [YOUR MAPPING]
BonusVault -> [YOUR MAPPING]
CrossFunctionVault -> [YOUR MAPPING]
ModifierBank -> [YOUR MAPPING]
SimpleDAO -> [YOUR MAPPING]
DAO -> [YOUR MAPPING]
Government -> [YOUR MAPPING]
Governmental -> [YOUR MAPPING]
Lottery -> [YOUR MAPPING]
Lotto -> [YOUR MAPPING]
CryptoRoulette -> [YOUR MAPPING]
BlackJack -> [YOUR MAPPING]
OddsAndEvens -> [YOUR MAPPING]
FiftyFlip -> [YOUR MAPPING]
GuessTheRandomNumberChallenge -> [YOUR MAPPING]
PredictTheBlockHashChallenge -> [YOUR MAPPING]
KingOfTheEtherThrone -> [YOUR MAPPING]
Rubixi -> [YOUR MAPPING]
LuckyDoubler -> [YOUR MAPPING]
Multiplicator -> [YOUR MAPPING]
MultiplicatorX3 -> [YOUR MAPPING]
MultiplicatorX4 -> [YOUR MAPPING]
PoCGame -> [YOUR MAPPING]
Ponzi -> [YOUR MAPPING]
GovernanceSystem -> [YOUR MAPPING]
VotingEscrow -> [YOUR MAPPING]
Staking -> [YOUR MAPPING]
StakingEvents -> [YOUR MAPPING]
RewardMinter -> [YOUR MAPPING]
GaugeV2 -> [YOUR MAPPING]
GaugeCL -> [YOUR MAPPING]
LendingPool -> [YOUR MAPPING]
LendingVault -> [YOUR MAPPING]
LendingProtocol -> [YOUR MAPPING]
LendingMarket -> [YOUR MAPPING]
BorrowerOperations -> [YOUR MAPPING]
LiquidityPool -> [YOUR MAPPING]
LiquidityBuffer -> [YOUR MAPPING]
AMMPool -> [YOUR MAPPING]
SwapRouter -> [YOUR MAPPING]
TokenPool -> [YOUR MAPPING]
YieldVault -> [YOUR MAPPING]
Strategy -> [YOUR MAPPING]
VaultStrategy -> [YOUR MAPPING]
VaultController -> [YOUR MAPPING]
VaultProxy -> [YOUR MAPPING]
PriceOracle -> [YOUR MAPPING]
CurveOracle -> [YOUR MAPPING]
ManipulableOracle -> [YOUR MAPPING]
CrossChainBridge -> [YOUR MAPPING]
BridgeRouter -> [YOUR MAPPING]
BridgeHandler -> [YOUR MAPPING]
BridgeReplica -> [YOUR MAPPING]
OrbitBridge -> [YOUR MAPPING]
PositionManager -> [YOUR MAPPING]
FundManager -> [YOUR MAPPING]
LockManagerBase -> [YOUR MAPPING]
LockManagerERC20 -> [YOUR MAPPING]
SessionSig -> [YOUR MAPPING]
BaseAuth -> [YOUR MAPPING]
BaseSig -> [YOUR MAPPING]
```

---

## CATEGORY 2: Function Names (289 unique)

Map these to medical actions/operations. Think: patient admission, discharge, treatment, diagnosis, prescription, billing, etc.

### Core Financial Operations
```
withdraw -> [YOUR MAPPING - e.g., dischargeFunds or releasePayment]
deposit -> [YOUR MAPPING - e.g., admitPayment or receivePayment]
transfer -> [YOUR MAPPING - e.g., relocateRecord or transferCare]
transferFrom -> [YOUR MAPPING]
approve -> [YOUR MAPPING - e.g., authorizeAccess or grantConsent]
allowance -> [YOUR MAPPING - e.g., accessLimit or consentLevel]
balanceOf -> [YOUR MAPPING - e.g., recordsOf or creditsOf]
totalSupply -> [YOUR MAPPING - e.g., totalCapacity or systemCapacity]
mint -> [YOUR MAPPING - e.g., issueCredential or createRecord]
burn -> [YOUR MAPPING - e.g., retireRecord or archiveCredential]
```

### State Management
```
pause -> [YOUR MAPPING - e.g., suspendOperations]
unpause -> [YOUR MAPPING - e.g., resumeOperations]
lock -> [YOUR MAPPING - e.g., quarantine or restrictAccess]
unlock -> [YOUR MAPPING - e.g., clearQuarantine or grantAccess]
freeze -> [YOUR MAPPING]
unfreeze -> [YOUR MAPPING]
```

### Ownership & Access
```
changeOwner -> [YOUR MAPPING - e.g., transferCustody]
transferOwnership -> [YOUR MAPPING]
setOwner -> [YOUR MAPPING]
addOwner -> [YOUR MAPPING]
removeOwner -> [YOUR MAPPING]
```

### Staking/Rewards
```
stake -> [YOUR MAPPING - e.g., enrollProgram or commitResources]
unstake -> [YOUR MAPPING]
claimReward -> [YOUR MAPPING - e.g., collectBenefit]
claimRewards -> [YOUR MAPPING]
getReward -> [YOUR MAPPING]
compound -> [YOUR MAPPING]
harvest -> [YOUR MAPPING]
earn -> [YOUR MAPPING]
```

### Lending/Borrowing
```
borrow -> [YOUR MAPPING - e.g., requestAdvance or obtainCredit]
repay -> [YOUR MAPPING - e.g., settleBalance]
liquidate -> [YOUR MAPPING - e.g., forceCollection]
supply -> [YOUR MAPPING]
redeem -> [YOUR MAPPING]
```

### Voting/Governance
```
vote -> [YOUR MAPPING - e.g., castDecision or submitPreference]
propose -> [YOUR MAPPING - e.g., submitProposal]
execute -> [YOUR MAPPING - e.g., implementDecision]
delegate -> [YOUR MAPPING - e.g., assignProxy]
```

### Trading/Exchange
```
buy -> [YOUR MAPPING - e.g., procureService]
sell -> [YOUR MAPPING - e.g., offerService]
swap -> [YOUR MAPPING - e.g., exchangeCredits]
exchange -> [YOUR MAPPING]
bid -> [YOUR MAPPING]
```

### Utility Functions
```
initialize -> [YOUR MAPPING - e.g., activateSystem]
init -> [YOUR MAPPING]
setup -> [YOUR MAPPING]
configure -> [YOUR MAPPING]
update -> [YOUR MAPPING]
upgrade -> [YOUR MAPPING]
migrate -> [YOUR MAPPING]
destroy -> [YOUR MAPPING]
kill -> [YOUR MAPPING]
```

### Query Functions
```
getBalance -> [YOUR MAPPING - e.g., checkCredits]
getPrice -> [YOUR MAPPING - e.g., retrieveCost]
getOwner -> [YOUR MAPPING]
getStatus -> [YOUR MAPPING]
calculate -> [YOUR MAPPING]
verify -> [YOUR MAPPING]
check -> [YOUR MAPPING]
validate -> [YOUR MAPPING]
```

### Additional Functions Found in Dataset
```
Participate -> [YOUR MAPPING]
Collect -> [YOUR MAPPING]
CashOut -> [YOUR MAPPING]
Deposit -> [YOUR MAPPING]
SetMinSum -> [YOUR MAPPING]
SetLogFile -> [YOUR MAPPING]
Initialized -> [YOUR MAPPING]
AddMessage -> [YOUR MAPPING]
WatchBalance -> [YOUR MAPPING]
CollectAllFees -> [YOUR MAPPING]
NextPayout -> [YOUR MAPPING]
PlayerInfo -> [YOUR MAPPING]
PayoutQueueSize -> [YOUR MAPPING]
PushBonusCode -> [YOUR MAPPING]
PopBonusCode -> [YOUR MAPPING]
UpdateBonusCodeAt -> [YOUR MAPPING]
withdrawAll -> [YOUR MAPPING]
withdrawBalance -> [YOUR MAPPING]
addToBalance -> [YOUR MAPPING]
getBalance -> [YOUR MAPPING]
forward -> [YOUR MAPPING]
sendTo -> [YOUR MAPPING]
refund -> [YOUR MAPPING]
refundAll -> [YOUR MAPPING]
refundBatched -> [YOUR MAPPING]
changePrice -> [YOUR MAPPING]
batchTransfer -> [YOUR MAPPING]
play -> [YOUR MAPPING]
playRandom -> [YOUR MAPPING]
playSystem -> [YOUR MAPPING]
won -> [YOUR MAPPING]
betOf -> [YOUR MAPPING]
betPrize -> [YOUR MAPPING]
invest -> [YOUR MAPPING]
investDirect -> [YOUR MAPPING]
disinvest -> [YOUR MAPPING]
payDividends -> [YOUR MAPPING]
commitDividend -> [YOUR MAPPING]
payWallet -> [YOUR MAPPING]
houseKeeping -> [YOUR MAPPING]
coldStore -> [YOUR MAPPING]
hotStore -> [YOUR MAPPING]
addHashes -> [YOUR MAPPING]
putHash -> [YOUR MAPPING]
getHash -> [YOUR MAPPING]
createAuction -> [YOUR MAPPING]
cancelAuction -> [YOUR MAPPING]
createProposal -> [YOUR MAPPING]
executeProposal -> [YOUR MAPPING]
closeProposal -> [YOUR MAPPING]
splitDAO -> [YOUR MAPPING]
newProposal -> [YOUR MAPPING]
```

---

## CATEGORY 3: Variable Names (198 unique)

Map these to medical data/state names. Think: patient records, medication dosages, treatment plans, billing amounts, etc.

### Balance & Amount Variables
```
balance -> [YOUR MAPPING - e.g., accountCredits or patientBalance]
balances -> [YOUR MAPPING]
amount -> [YOUR MAPPING - e.g., dosage or quantity]
value -> [YOUR MAPPING - e.g., assessment or measurement]
price -> [YOUR MAPPING - e.g., serviceCost or treatmentFee]
fee -> [YOUR MAPPING - e.g., consultationFee]
fees -> [YOUR MAPPING]
total -> [YOUR MAPPING]
sum -> [YOUR MAPPING]
```

### User/Account Variables
```
owner -> [YOUR MAPPING - e.g., primaryCaregiver or custodian]
admin -> [YOUR MAPPING - e.g., chiefMedicalOfficer]
user -> [YOUR MAPPING - e.g., patient]
sender -> [YOUR MAPPING - e.g., requestor]
recipient -> [YOUR MAPPING - e.g., beneficiary]
spender -> [YOUR MAPPING - e.g., serviceProvider]
```

### State Variables
```
paused -> [YOUR MAPPING - e.g., suspended]
locked -> [YOUR MAPPING - e.g., restricted]
active -> [YOUR MAPPING - e.g., operational]
initialized -> [YOUR MAPPING - e.g., activated]
enabled -> [YOUR MAPPING]
blocked -> [YOUR MAPPING]
```

### Token/Asset Variables
```
token -> [YOUR MAPPING - e.g., credential or certificate]
tokens -> [YOUR MAPPING]
tokenId -> [YOUR MAPPING - e.g., recordId]
supply -> [YOUR MAPPING - e.g., inventory or capacity]
allowance -> [YOUR MAPPING - e.g., authorizedLimit]
allowed -> [YOUR MAPPING - e.g., authorizedAccess]
```

### Additional Variables Found
```
userBalance -> [YOUR MAPPING]
sellerBalance -> [YOUR MAPPING]
investBalance -> [YOUR MAPPING]
walletBalance -> [YOUR MAPPING]
MinSum -> [YOUR MAPPING]
MinDeposit -> [YOUR MAPPING]
WinningPot -> [YOUR MAPPING]
Last_Payout -> [YOUR MAPPING]
Payout_id -> [YOUR MAPPING]
jackpot -> [YOUR MAPPING]
betAmount -> [YOUR MAPPING]
betHash -> [YOUR MAPPING]
betLimit -> [YOUR MAPPING]
players -> [YOUR MAPPING]
participants -> [YOUR MAPPING]
investors -> [YOUR MAPPING]
depositors -> [YOUR MAPPING]
withdrawals -> [YOUR MAPPING]
deposits -> [YOUR MAPPING]
refundAmount -> [YOUR MAPPING]
refundAddresses -> [YOUR MAPPING]
nextIdx -> [YOUR MAPPING]
creator -> [YOUR MAPPING]
animator -> [YOUR MAPPING]
curator -> [YOUR MAPPING]
dividends -> [YOUR MAPPING]
dividendPeriod -> [YOUR MAPPING]
hashFirst -> [YOUR MAPPING]
hashLast -> [YOUR MAPPING]
hashNext -> [YOUR MAPPING]
hashBetSum -> [YOUR MAPPING]
hashBetMax -> [YOUR MAPPING]
hashes -> [YOUR MAPPING]
coldStoreLast -> [YOUR MAPPING]
proposals -> [YOUR MAPPING]
proposalCount -> [YOUR MAPPING]
proposalDeposit -> [YOUR MAPPING]
minQuorumDivisor -> [YOUR MAPPING]
votes -> [YOUR MAPPING]
voters -> [YOUR MAPPING]
delegations -> [YOUR MAPPING]
rewards -> [YOUR MAPPING]
rewardRate -> [YOUR MAPPING]
rewardToken -> [YOUR MAPPING]
staked -> [YOUR MAPPING]
stakes -> [YOUR MAPPING]
stakingToken -> [YOUR MAPPING]
liquidity -> [YOUR MAPPING]
reserves -> [YOUR MAPPING]
collateral -> [YOUR MAPPING]
debt -> [YOUR MAPPING]
borrowed -> [YOUR MAPPING]
supplied -> [YOUR MAPPING]
interestRate -> [YOUR MAPPING]
exchangeRate -> [YOUR MAPPING]
oracle -> [YOUR MAPPING]
priceOracle -> [YOUR MAPPING]
```

---

## CATEGORY 4: Event Names (87 unique)

Map these to medical event/notification names.

```
Transfer -> [YOUR MAPPING - e.g., RecordTransfer or CareHandoff]
Approval -> [YOUR MAPPING - e.g., ConsentGranted or AccessAuthorized]
Deposit -> [YOUR MAPPING - e.g., PaymentReceived or FundsAdmitted]
Withdrawal -> [YOUR MAPPING - e.g., FundsDischarged or PaymentReleased]
Pause -> [YOUR MAPPING - e.g., OperationsSuspended]
Unpause -> [YOUR MAPPING - e.g., OperationsResumed]
OwnershipTransferred -> [YOUR MAPPING - e.g., CustodyTransferred]
Mint -> [YOUR MAPPING - e.g., CredentialIssued]
Burn -> [YOUR MAPPING - e.g., RecordArchived]
Staked -> [YOUR MAPPING - e.g., ResourcesCommitted]
Withdraw -> [YOUR MAPPING]
Borrow -> [YOUR MAPPING]
Repay -> [YOUR MAPPING]
Liquidate -> [YOUR MAPPING]
Swap -> [YOUR MAPPING]
Vote -> [YOUR MAPPING]
Voted -> [YOUR MAPPING]
ProposalCreated -> [YOUR MAPPING]
ProposalExecuted -> [YOUR MAPPING]
LogBet -> [YOUR MAPPING]
LogWin -> [YOUR MAPPING]
LogLoss -> [YOUR MAPPING]
LogInvestment -> [YOUR MAPPING]
LogDividend -> [YOUR MAPPING]
LogRecordWin -> [YOUR MAPPING]
LogLate -> [YOUR MAPPING]
Birth -> [YOUR MAPPING]
Pregnant -> [YOUR MAPPING]
AuctionCreated -> [YOUR MAPPING]
AuctionSuccessful -> [YOUR MAPPING]
AuctionCancelled -> [YOUR MAPPING]
```

---

## CATEGORY 5: Modifier Names (48 unique)

Map these to medical access control concepts.

```
onlyOwner -> [YOUR MAPPING - e.g., onlyPrimaryCare or onlyCustodian]
onlyAdmin -> [YOUR MAPPING - e.g., onlyMedicalDirector]
whenNotPaused -> [YOUR MAPPING - e.g., whenOperational]
whenPaused -> [YOUR MAPPING - e.g., whenSuspended]
nonReentrant -> [YOUR MAPPING - e.g., singleAccess]
onlyMinter -> [YOUR MAPPING]
onlyOperator -> [YOUR MAPPING]
onlyAnimator -> [YOUR MAPPING]
onlyCEO -> [YOUR MAPPING]
onlyCFO -> [YOUR MAPPING]
onlyCOO -> [YOUR MAPPING]
onlyCLevel -> [YOUR MAPPING]
onlyTokenholders -> [YOUR MAPPING]
onlyPlayers -> [YOUR MAPPING]
validAddress -> [YOUR MAPPING]
notZeroAddress -> [YOUR MAPPING]
checkContractHealth -> [YOUR MAPPING]
gameIsGoingOn -> [YOUR MAPPING]
hasNoBalance -> [YOUR MAPPING]
isOpenToPublic -> [YOUR MAPPING]
```

---

## CATEGORY 6: Struct Names (42 unique)

Map these to medical data structure names.

```
Wallet -> [YOUR MAPPING - e.g., PatientAccount]
Player -> [YOUR MAPPING - e.g., Participant or Enrollee]
Bet -> [YOUR MAPPING - e.g., ServiceRequest]
Proposal -> [YOUR MAPPING - e.g., TreatmentProposal]
Transaction -> [YOUR MAPPING - e.g., MedicalTransaction]
Message -> [YOUR MAPPING - e.g., ClinicalNote]
Auction -> [YOUR MAPPING - e.g., ServiceListing]
Position -> [YOUR MAPPING - e.g., CarePosition]
Channel -> [YOUR MAPPING - e.g., CommunicationChannel]
Token -> [YOUR MAPPING - e.g., Credential]
User -> [YOUR MAPPING - e.g., Patient]
Campaign -> [YOUR MAPPING - e.g., HealthProgram]
Round -> [YOUR MAPPING - e.g., TreatmentCycle]
Entry -> [YOUR MAPPING - e.g., MedicalEntry]
Holder -> [YOUR MAPPING - e.g., RecordHolder]
Market -> [YOUR MAPPING - e.g., ServiceMarket]
```

---

## Important Notes

1. **Consistency**: If you map `balance` to `patientCredits`, use similar patterns for related terms like `balances` -> `patientCreditsMap`

2. **Compound words**: For compound identifiers like `getUserBalance`, break them down:
   - `get` + `User` + `Balance` -> `retrieve` + `Patient` + `Credits` = `retrievePatientCredits`

3. **Preserve meaning**: A `withdraw` function that removes funds should map to something like `dischargeFunds` or `releasePayment`, not `prescribeMedication`

4. **Skip if unsure**: If you're not sure about a mapping, skip it. It's better to have fewer good mappings than many poor ones.

5. **Domain authenticity**: Your mappings should sound like they belong in a real healthcare system, not just random medical words attached to programming concepts.

---

## Deliverable

Return your completed mappings in the same format, organized by category. Only include identifiers you are mapping (skip those you leave unchanged).

Example output format:
```
## CATEGORY 1: Contract Names
TokenVault -> PatientRecordsVault
CrowdFundBasic -> CommunityHealthFund
...

## CATEGORY 2: Function Names
withdraw -> dischargeFunds
deposit -> admitPayment
...
```
