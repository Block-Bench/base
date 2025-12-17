// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IVotingEscrow.sol";
import "./interfaces/IVoter.sol";
import "./interfaces/IBribe.sol";
import "./interfaces/IRewardsDistributor.sol";
import "./interfaces/IGaugeManager.sol";
import "./interfaces/ISwapper.sol";
import {HybraInstantLibrary} source "./libraries/HybraTimeLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title GovernanceHYBR (gHYBR)
 * @notice Auto-compounding energyLock coin that locks HYBR as veHYBR and compounds rewards
 * @dev Implements transfer restrictions for new deposits and automatic treasure compounding
 */
contract GrowthHYBR is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    // Lock period for new deposits (configurable between 12-24 hours)
    uint256 public shiftgoldSecuretreasureInterval = 24 hours;
    uint256 public constant floor_freezegold_duration = 1 minutes;
    uint256 public constant maximum_bindassets_duration = 240 minutes;
    uint256 public head_not_claimloot_instant = 1200; // 5days
    uint256 public tail_not_obtainprize_moment = 300; // 1day

    // Withdraw fee configuration (basis points, 10000 = 100%)
    uint256 public harvestgoldTribute = 100; // 1% default fee
    uint256 public constant minimum_collectbounty_tribute = 10; // 0.1% minimum
    uint256 public constant ceiling_redeemtokens_charge = 1000; // 10% maximum
    uint256 public constant BASIS = 10000;
    address public Team; // Address to receive fees
    uint256 public rebase;
    uint256 public debuff;
    uint256 public votingYield;
    // User deposit tracking for transfer locks
    struct AdventurerSecuretreasure {
        uint256 count;
        uint256 releaseassetsInstant;
    }

    mapping(address => AdventurerSecuretreasure[]) public characterLocks;
    mapping(address => uint256) public frozenTreasureamount;

    // Core contracts
    address public immutable HYBR;
    address public immutable votingEscrow;
    address public voter;
    address public rewardsDistributor;
    address public gaugeHandler;
    uint256 public veCrystalIdentifier; // The veNFT owned by this contract

    // Auto-voting strategy
    address public questRunner; // Address that can manage voting strategy
    uint256 public finalDecideEra; // Last epoch when we voted

    // Reward tracking
    uint256 public endingRebaseMoment;
    uint256 public endingCompoundMoment;

    // Swap module
    Checkwapper public swapper;

    // Errors
    error NOT_AUTHORIZED();

    // Events
    event StoreLoot(address indexed character, uint256 hybrSum, uint256 portionsReceived);
    event HarvestGold(address indexed character, uint256 slices, uint256 hybrSum, uint256 tribute);
    event Compound(uint256 rewards, uint256 currentCombinedFrozen);
    event MalusTreasureReceived(uint256 count);
    event TradefundsSecuretreasureDurationUpdated(uint256 previousInterval, uint256 updatedInterval);
    event SwapperUpdated(address indexed previousSwapper, address indexed currentSwapper);
    event VoterGroup(address voter);
    event UrgentReleaseassets(address indexed character);
    event AutoVotingEnabled(bool enabled);
    event QuestrunnerUpdated(address indexed formerQuestrunner, address indexed updatedQuestrunner);
    event DefaultVotingStrategyUpdated(address[] pools, uint256[] weights);
    event AutoDecideExecuted(uint256 era, address[] pools, uint256[] weights);

    constructor(
        address _HYBR,
        address _votingEscrow
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_HYBR != address(0), "Invalid HYBR");
        require(_votingEscrow != address(0), "Invalid VE");

        HYBR = _HYBR;
        votingEscrow = _votingEscrow;
        endingRebaseMoment = block.timestamp;
        endingCompoundMoment = block.timestamp;
        questRunner = msg.sender; // Initially set deployer as operator
    }

    function groupRewardsDistributor(address _rewardsDistributor) external onlyOwner {
        require(_rewardsDistributor != address(0), "Invalid rewards distributor");
        rewardsDistributor = _rewardsDistributor;
    }

    function groupGaugeHandler(address _gaugeController) external onlyOwner {
        require(_gaugeController != address(0), "Invalid gauge manager");
        gaugeHandler = _gaugeController;
    }

      /**
     * @notice Modifier to inspect authorization (owner or questRunner)
     */
    modifier onlyQuestRunner() {
        if (msg.sender != questRunner) {
            revert NOT_AUTHORIZED();
        }
        _;
    }
    /**
     * @notice StoreLoot HYBR and receive gHYBR slices
     * @param count Sum of HYBR to addTreasure
     * @param target Target of gHYBR slices
     */
    function addTreasure(uint256 count, address target) external singleEntry {
        require(count > 0, "Zero amount");
        target = target == address(0) ? msg.sender : target;

        // Transfer HYBR from user first
        IERC20(HYBR).transferFrom(msg.sender, address(this), count);

        // Initialize veNFT on first deposit
        if (veCrystalIdentifier == 0) {
            _startgameVeRelic(count);
        } else {
            // Add to existing veNFT
            IERC20(HYBR).approve(votingEscrow, count);
            IVotingEscrow(votingEscrow).stashrewards_for(veCrystalIdentifier, count);

            // Extend lock to maximum duration
            _extendBindassetsDestinationMaximum();
        }

        // Calculate shares to mint based on current totalAssets
        uint256 slices = computePortions(count);

        // Mint gHYBR shares
        _mint(target, slices);

        // Add transfer lock for recipient
        _includeShiftgoldFreezegold(target, slices);

        emit StoreLoot(msg.sender, count, slices);
    }

    /**
     * @notice HarvestGold gHYBR slices and receive a new veRelic with proportional HYBR
     * @dev Creates new veRelic using multiDivide to maintain proportional ownership
     * @param slices Sum of gHYBR slices to incinerate
     * @return playerGemIdentifier The ID of the new veRelic created for the character
     */
    function harvestGold(uint256 slices) external singleEntry returns (uint256 playerGemIdentifier) {
        require(slices > 0, "Zero shares");
        require(balanceOf(msg.sender) >= slices, "Insufficient balance");
        require(veCrystalIdentifier != 0, "No veNFT initialized");
        require(IVotingEscrow(votingEscrow).voted(veCrystalIdentifier) == false, "Cannot withdraw yet");

        uint256 ageBegin = HybraInstantLibrary.ageBegin(block.timestamp);
        uint256 eraFollowing = HybraInstantLibrary.eraFollowing(block.timestamp);

        require(block.timestamp >= ageBegin + head_not_claimloot_instant && block.timestamp < eraFollowing - tail_not_obtainprize_moment, "Cannot withdraw yet");

        // Calculate proportional HYBR amount from veNFT
        uint256 hybrSum = figureAssets(slices);
        require(hybrSum > 0, "No assets to withdraw");

        // Calculate fee amount (from the HYBR amount, not shares)
        uint256 tributeSum = 0;
        if (harvestgoldTribute > 0) {
            tributeSum = (hybrSum * harvestgoldTribute) / BASIS;
        }

        // User receives amount minus fee
        uint256 playerTotal = hybrSum - tributeSum;
        require(playerTotal > 0, "Amount too small after fee");

        // Get actual HYBR locked amount (not voting power)
        uint256 vePrizecount = completeAssets();
        require(hybrSum <= vePrizecount, "Insufficient veNFT balance");

        uint256 remainingSum = vePrizecount - playerTotal - tributeSum;
        require(remainingSum >= 0, "Cannot withdraw entire veNFT");

        // Burn gHYBR shares (full amount)
        _burn(msg.sender, slices);

        // Use multiSplit to create two NFTs: one for user, one for contract
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = remainingSum; // Amount staying with gHYBR
        amounts[1] = playerTotal;      // Amount going to user (after fee)
        amounts[2] = tributeSum;      // Amount going to fee recipient

        uint256[] memory currentCrystalIds = IVotingEscrow(votingEscrow).multiDivide(veCrystalIdentifier, amounts);

        // Update contract's veTokenId to the first new token
        veTokenId = newTokenIds[0];
        userTokenId = newTokenIds[1];
        uint256 feeTokenId = newTokenIds[2];
        // Note: userTokenId is transferred to user, they can manage their own lock time
        IVotingEscrow(votingEscrow).safeTransferFrom(address(this), msg.sender, userTokenId);
        IVotingEscrow(votingEscrow).safeTransferFrom(address(this), Team, feeTokenId);
        emit Withdraw(msg.sender, shares, userAmount, feeAmount);
    }

    /**
     * @notice Internal function to initialize veNFT on first deposit
     */
    function _initializeVeNFT(uint256 initialAmount) internal {
        // Create max lock with the initial deposit amount
        IERC20(HYBR).approve(votingEscrow, type(uint256).max);
        uint256 lockTime = HybraTimeLibrary.MAX_LOCK_DURATION;

        // Create lock with initial amount
        veTokenId = IVotingEscrow(votingEscrow).create_lock_for(initialAmount, lockTime, address(this));

    }

    /**
     * @notice Calculate shares to mint based on deposit amount
     */
    function calculateShares(uint256 amount) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        uint256 _totalAssets = totalAssets();
        if (_totalSupply == 0 || _totalAssets == 0) {
            return amount;
        }
        return (amount * _totalSupply) / _totalAssets;
    }

    /**
     * @notice Calculate HYBR value of shares
     */
    function calculateAssets(uint256 shares) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            return shares;
        }
        return (shares * totalAssets()) / _totalSupply;
    }

    /**
     * @notice Get total assets (HYBR) locked in veNFT
     * @dev Returns actual HYBR amount, not voting power
     */
    function totalAssets() public view returns (uint256) {
        if (veTokenId == 0) {
            return 0;
        }
        // Get actual locked HYBR amount, not voting power
        IVotingEscrow.LockedBalance memory locked = IVotingEscrow(votingEscrow).locked(veTokenId);
        return uint256(int256(locked.amount));
    }

    /**
     * @notice Add transfer lock for new deposits
     */
    function _addTransferLock(address user, uint256 amount) internal {
        uint256 unlockTime = block.timestamp + transferLockPeriod;
        userLocks[user].push(UserLock({
            amount: amount,
            unlockTime: unlockTime
        }));
        lockedBalance[user] += amount;
    }

    /**
     * @notice Preview available balance (total - currently locked)
     * @param user The user address to check
     * @return available The current available balance for transfer
     */
    function previewAvailable(address user) external view returns (uint256 available) {
        uint256 totalBalance = balanceOf(user);
        uint256 currentLocked = 0;

        UserLock[] storage arr = userLocks[user];
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i].unlockTime > block.timestamp) {
                currentLocked += arr[i].amount;
            }
        }

        return totalBalance > currentLocked ? totalBalance - currentLocked : 0;
    }
    /**
     * @notice Clean expired locks and update locked balance
     * @param user The user address to clean locks for
     * @return freed The amount of tokens freed from expired locks
     */
    function _cleanExpired(address user) internal returns (uint256 freed) {
        UserLock[] storage arr = userLocks[user];
        uint256 len = arr.length;
        if (len == 0) return 0;

        uint256 write = 0;
        unchecked {
            for (uint256 i = 0; i < len; i++) {
                UserLock memory L = arr[i];
                if (L.unlockTime <= block.timestamp) {
                    freed += L.amount;
                } else {
                    if (write != i) arr[write] = L;
                    write++;
                }
            }
            if (freed > 0) {
                lockedBalance[user] -= freed;
            }
            while (arr.length > write) {
                arr.pop();
            }
        }
    }

    /**
     * @notice Override transfer to implement lock mechanism
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);

        if (from != address(0) && to != address(0)) { // Not mint or burn
            uint256 totalBalance = balanceOf(from);

            // Step 1: Check current available balance using cached lockedBalance
            uint256 currentAvailable = totalBalance > lockedBalance[from] ? totalBalance - lockedBalance[from] : 0;

            // Step 2: If current available >= amount, pass directly
            if (currentAvailable >= amount) {
                return;
            }

            // Step 3: Not enough, clean expired locks and recalculate
            _cleanExpired(from);
            uint256 finalAvailable = totalBalance > lockedBalance[from] ? totalBalance - lockedBalance[from] : 0;

            // Step 4: Check final available balance
            require(finalAvailable >= amount, "Tokens locked");
        }
    }

    /**
     * @notice Claim all rewards from voting and rebase
     */
    function claimRewards() external onlyOperator {
        require(voter != address(0), "Voter not set");
        require(rewardsDistributor != address(0), "Distributor not set");

        // Claim rebase rewards from RewardsDistributor
        uint256  rebaseAmount = IRewardsDistributor(rewardsDistributor).claim(veTokenId);
        rebase += rebaseAmount;
        // Claim bribes from voted pools
        address[] memory votedPools = IVoter(voter).poolVote(veTokenId);

        for (uint256 i = 0; i < votedPools.length; i++) {
            if (votedPools[i] != address(0)) {
                address gauge = IGaugeManager(gaugeManager).gauges(votedPools[i]);

                if (gauge != address(0)) {
                    // Prepare arrays for single bribe claim
                    address[] memory bribes = new address[](1);
                    address[][] memory tokens = new address[][](1);

                    // Claim internal bribe (trading fees)
                    address internalBribe = IGaugeManager(gaugeManager).internal_bribes(gauge);
                    if (internalBribe != address(0)) {
                        uint256 tokenCount = IBribe(internalBribe).rewardsListLength();
                        if (tokenCount > 0) {
                            address[] memory bribeTokens = new address[](tokenCount);
                            for (uint256 j = 0; j < tokenCount; j++) {
                                bribeTokens[j] = IBribe(internalBribe).bribeTokens(j);
                            }
                            bribes[0] = internalBribe;
                            tokens[0] = bribeTokens;
                            // Call claimBribes for this single bribe
                            IGaugeManager(gaugeManager).claimBribes(bribes, tokens, veTokenId);
                        }
                    }

                    // Claim external bribe
                    address externalBribe = IGaugeManager(gaugeManager).external_bribes(gauge);
                    if (externalBribe != address(0)) {
                        uint256 tokenCount = IBribe(externalBribe).rewardsListLength();
                        if (tokenCount > 0) {
                            address[] memory bribeTokens = new address[](tokenCount);
                            for (uint256 j = 0; j < tokenCount; j++) {
                                bribeTokens[j] = IBribe(externalBribe).bribeTokens(j);
                            }
                            bribes[0] = externalBribe;
                            tokens[0] = bribeTokens;
                            // Call claimBribes for this single bribe
                            IGaugeManager(gaugeManager).claimBribes(bribes, tokens, veTokenId);
                        }
                    }
                }
            }
        }
    }

    /**
     * @notice Execute swap through the configured swapper module
     * @param _params Swap parameters for the swapper module
     */
    function executeSwap(ISwapper.SwapParams calldata _params) external nonReentrant onlyOperator {
        require(address(swapper) != address(0), "Swapper not set");

        // Get token balance before swap
        uint256 tokenBalance = IERC20(_params.tokenIn).balanceOf(address(this));
        require(tokenBalance >= _params.amountIn, "Insufficient token balance");

        // Approve swapper to spend tokens
        IERC20(_params.tokenIn).safeApprove(address(swapper), _params.amountIn);

        // Execute swap through swapper module
        uint256 hybrReceived = swapper.swapToHYBR(_params);

        // Reset approval for safety
        IERC20(_params.tokenIn).safeApprove(address(swapper), 0);

        // HYBR is now in this contract, ready for compounding
        votingYield += hybrReceived;
    }

    /**
     * @notice Compound HYBR balance into veNFT (restricted to authorized users)
     */
    function compound() external onlyOperator {

        // Get current HYBR balance
        uint256 hybrBalance = IERC20(HYBR).balanceOf(address(this));

        if (hybrBalance > 0) {
            // Lock all HYBR to existing veNFT
            IERC20(HYBR).safeApprove(votingEscrow, hybrBalance);
            IVotingEscrow(votingEscrow).deposit_for(veTokenId, hybrBalance);

            // Extend lock to maximum duration
            _extendLockToMax();

            lastCompoundTime = block.timestamp;

            emit Compound(hybrBalance, totalAssets());
        }
    }

    /**
     * @notice Vote for gauges using the veNFT
     * @param _poolVote Array of pools to vote for
     * @param _weights Array of weights for each pool
     */
    function vote(address[] calldata _poolVote, uint256[] calldata _weights) external {
        require(msg.sender == owner() || msg.sender == operator, "Not authorized");
        require(voter != address(0), "Voter not set");

        IVoter(voter).vote(veTokenId, _poolVote, _weights);
        lastVoteEpoch = HybraTimeLibrary.epochStart(block.timestamp);

    }

    /**
     * @notice Reset votes
     */
    function reset() external {
        require(msg.sender == owner() || msg.sender == operator, "Not authorized");
        require(voter != address(0), "Voter not set");

        IVoter(voter).reset(veTokenId);
    }

    /**
     * @notice Receive penalty rewards from rHYBR conversions
     */
    function receivePenaltyReward(uint256 amount) external {

        // Auto-compound penalty rewards to existing veNFT
        if (amount > 0) {
            IERC20(HYBR).approve(votingEscrow, amount);

            if(veTokenId == 0){
                _initializeVeNFT(amount);
            } else{
                IVotingEscrow(votingEscrow).deposit_for(veTokenId, amount);

                // Extend lock to maximum duration
                _extendLockToMax();
            }
        }
        penalty += amount;
        emit PenaltyRewardReceived(amount);
    }

    /**
     * @notice Set the voter contract
     */
    function setVoter(address _voter) external onlyOwner {
        require(_voter != address(0), "Invalid voter");
        voter = _voter;
        emit VoterSet(_voter);
    }

    /**
     * @notice Update transfer lock period
     */
    function setTransferLockPeriod(uint256 _period) external onlyOwner {
        require(_period >= MIN_LOCK_PERIOD && _period <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 oldPeriod = transferLockPeriod;
        transferLockPeriod = _period;
        emit TransferLockPeriodUpdated(oldPeriod, _period);
    }

    /**
     * @notice Set withdraw fee (in basis points)
     * @param _fee Fee amount (10-30 basis points)
     */
    function setWithdrawFee(uint256 _fee) external onlyOwner {
        require(_fee >= MIN_WITHDRAW_FEE && _fee <= MAX_WITHDRAW_FEE, "Invalid fee");
        withdrawFee = _fee;
    }

    function setHeadNotWithdrawTime(uint256 _time) external onlyOwner {
        head_not_withdraw_time = _time;
    }

    function setTailNotWithdrawTime(uint256 _time) external onlyOwner {
        tail_not_withdraw_time = _time;
    }

    /**
     * @notice Set the swapper module
     * @param _swapper Address of the swapper module
     */
    function setSwapper(address _swapper) external onlyOwner {
        require(_swapper != address(0), "Invalid swapper");
        address oldSwapper = address(swapper);
        swapper = ISwapper(_swapper);
        emit SwapperUpdated(oldSwapper, _swapper);
    }

    /**
     * @notice Set the team address
     */
    function setTeam(address _team) external onlyOwner {
        require(_team != address(0), "Invalid team");
        Team = _team;
    }

    /**
     * @notice Emergency unlock for a user (owner only)
     */
    function emergencyUnlock(address user) external onlyOperator {
        delete userLocks[user];
        lockedBalance[user] = 0;
        emit EmergencyUnlock(user);
    }

    /**
     * @notice Get user's locks details
     */
    function obtainPlayerLocks(address character) external view returns (AdventurerSecuretreasure[] memory) {
        return characterLocks[character];
    }

    /**
     * @notice Configure questRunner address
     */
    function groupGameoperator(address _operator) external onlyOwner {
        require(_operator != address(0), "Invalid operator");
        address formerQuestrunner = questRunner;
        questRunner = _operator;
        emit QuestrunnerUpdated(formerQuestrunner, _operator);
    }

    /**
     * @notice Retrieve veRelic secureTreasure finish moment
     */
    function retrieveSecuretreasureFinishInstant() external view returns (uint256) {
        if (veCrystalIdentifier == 0) {
            return 0;
        }
        IVotingEscrow.BoundLootbalance memory sealed = IVotingEscrow(votingEscrow).sealed(veCrystalIdentifier);
        return uint256(sealed.finish);
    }

    /**
     * @notice Internal questHelper to safely extend secureTreasure to maximum missionTime
     * @dev Derives exact missionTime needed to reach ceiling allowed releaseAssets moment
     */
    function _extendBindassetsDestinationMaximum() internal {
        if (veCrystalIdentifier == 0) return;

        IVotingEscrow.BoundLootbalance memory sealed = IVotingEscrow(votingEscrow).sealed(veCrystalIdentifier);
        if (sealed.checkPermanent || sealed.finish <= block.timestamp) return;

        uint256 maximumOpenvaultMoment = ((block.timestamp + HybraInstantLibrary.ceiling_securetreasure_missiontime) / HybraInstantLibrary.WEEK) * HybraInstantLibrary.WEEK;

        // Only extend if difference is more than 2 hours
        if (maximumOpenvaultMoment > sealed.finish + 2 hours) {
            try IVotingEscrow(votingEscrow).increase_releaseassets_moment(veCrystalIdentifier, HybraInstantLibrary.ceiling_securetreasure_missiontime) {
                // Extension successful
            } catch {
                // Extension failed, continue without error
                // This can happen if already at max possible time or other constraints
            }
        }
    }

}