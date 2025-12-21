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
import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract GrowthHYBR is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public transferLockPeriod = 24 hours;
    uint256 public constant MIN_LOCK_PERIOD = 1 minutes;
    uint256 public constant MAX_LOCK_PERIOD = 240 minutes;
    uint256 public head_not_withdraw_time = 1200;
    uint256 public tail_not_withdraw_time = 300;


    uint256 public withdrawFee = 100;
    uint256 public constant MIN_WITHDRAW_FEE = 10;
    uint256 public constant MAX_WITHDRAW_FEE = 1000;
    uint256 public constant BASIS = 10000;
    address public Team;
    uint256 public rebase;
    uint256 public penalty;
    uint256 public votingYield;

    struct UserLock {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => UserLock[]) public userLocks;
    mapping(address => uint256) public lockedBalance;


    address public immutable HYBR;
    address public immutable votingEscrow;
    address public voter;
    address public rewardsDistributor;
    address public gaugeManager;
    uint256 public veTokenId;


    address public operator;
    uint256 public lastVoteEpoch;


    uint256 public lastRebaseTime;
    uint256 public lastCompoundTime;


    ISwapper public swapper;


    error NOT_AUTHORIZED();


    event Deposit(address indexed user, uint256 hybrAmount, uint256 sharesReceived);
    event Withdraw(address indexed user, uint256 shares, uint256 hybrAmount, uint256 fee);
    event Compound(uint256 rewards, uint256 newTotalLocked);
    event PenaltyRewardReceived(uint256 amount);
    event TransferLockPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);
    event SwapperUpdated(address indexed oldSwapper, address indexed newSwapper);
    event VoterSet(address voter);
    event EmergencyUnlock(address indexed user);
    event AutoVotingEnabled(bool enabled);
    event OperatorUpdated(address indexed oldOperator, address indexed newOperator);
    event DefaultVotingStrategyUpdated(address[] pools, uint256[] weights);
    event AutoVoteExecuted(uint256 epoch, address[] pools, uint256[] weights);

    constructor(
        address _HYBR,
        address _votingEscrow
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_HYBR != address(0), "Invalid HYBR");
        require(_votingEscrow != address(0), "Invalid VE");

        HYBR = _HYBR;
        votingEscrow = _votingEscrow;
        lastRebaseTime = block.timestamp;
        lastCompoundTime = block.timestamp;
        operator = msg.sender;
    }

    function setRewardsDistributor(address _rewardsDistributor) external onlyOwner {
        require(_rewardsDistributor != address(0), "Invalid rewards distributor");
        rewardsDistributor = _rewardsDistributor;
    }

    function setGaugeManager(address _gaugeManager) external onlyOwner {
        require(_gaugeManager != address(0), "Invalid gauge manager");
        gaugeManager = _gaugeManager;
    }


    modifier onlyOperator() {
        if (msg.sender != operator) {
            revert NOT_AUTHORIZED();
        }
        _;
    }

    function deposit(uint256 amount, address recipient) external nonReentrant {
        require(amount > 0, "Zero amount");
        recipient = recipient == address(0) ? msg.sender : recipient;


        IERC20(HYBR).transferFrom(msg.sender, address(this), amount);


        if (veTokenId == 0) {
            _initializeVeNFT(amount);
        } else {

            IERC20(HYBR).approve(votingEscrow, amount);
            IVotingEscrow(votingEscrow).deposit_for(veTokenId, amount);


            _extendLockToMax();
        }


        uint256 shares = calculateShares(amount);


        _mint(recipient, shares);


        _addTransferLock(recipient, shares);

        emit Deposit(msg.sender, amount, shares);
    }


    function withdraw(uint256 shares) external nonReentrant returns (uint256 userTokenId) {
        require(shares > 0, "Zero shares");
        require(balanceOf(msg.sender) >= shares, "Insufficient balance");
        require(veTokenId != 0, "No veNFT initialized");
        require(IVotingEscrow(votingEscrow).voted(veTokenId) == false, "Cannot withdraw yet");

        uint256 epochStart = HybraTimeLibrary.epochStart(block.timestamp);
        uint256 epochNext = HybraTimeLibrary.epochNext(block.timestamp);

        require(block.timestamp >= epochStart + head_not_withdraw_time && block.timestamp < epochNext - tail_not_withdraw_time, "Cannot withdraw yet");


        uint256 hybrAmount = calculateAssets(shares);
        require(hybrAmount > 0, "No assets to withdraw");


        uint256 feeAmount = 0;
        if (withdrawFee > 0) {
            feeAmount = (hybrAmount * withdrawFee) / BASIS;
        }


        uint256 userAmount = hybrAmount - feeAmount;
        require(userAmount > 0, "Amount too small after fee");


        uint256 veBalance = totalAssets();
        require(hybrAmount <= veBalance, "Insufficient veNFT balance");

        uint256 remainingAmount = veBalance - userAmount - feeAmount;
        require(remainingAmount >= 0, "Cannot withdraw entire veNFT");


        _burn(msg.sender, shares);


        uint256[] memory amounts = new uint256[](3);
        amounts[0] = remainingAmount;
        amounts[1] = userAmount;
        amounts[2] = feeAmount;

        uint256[] memory newTokenIds = IVotingEscrow(votingEscrow).multiSplit(veTokenId, amounts);


        veTokenId = newTokenIds[0];
        userTokenId = newTokenIds[1];
        uint256 feeTokenId = newTokenIds[2];

        IVotingEscrow(votingEscrow).safeTransferFrom(address(this), msg.sender, userTokenId);
        IVotingEscrow(votingEscrow).safeTransferFrom(address(this), Team, feeTokenId);
        emit Withdraw(msg.sender, shares, userAmount, feeAmount);
    }


    function _initializeVeNFT(uint256 initialAmount) internal {

        IERC20(HYBR).approve(votingEscrow, type(uint256).max);
        uint256 lockTime = HybraTimeLibrary.MAX_LOCK_DURATION;


        veTokenId = IVotingEscrow(votingEscrow).create_lock_for(initialAmount, lockTime, address(this));

    }


    function calculateShares(uint256 amount) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        uint256 _totalAssets = totalAssets();
        if (_totalSupply == 0 || _totalAssets == 0) {
            return amount;
        }
        return (amount * _totalSupply) / _totalAssets;
    }


    function calculateAssets(uint256 shares) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            return shares;
        }
        return (shares * totalAssets()) / _totalSupply;
    }


    function totalAssets() public view returns (uint256) {
        if (veTokenId == 0) {
            return 0;
        }

        IVotingEscrow.LockedBalance memory locked = IVotingEscrow(votingEscrow).locked(veTokenId);
        return uint256(int256(locked.amount));
    }


    function _addTransferLock(address user, uint256 amount) internal {
        uint256 unlockTime = block.timestamp + transferLockPeriod;
        userLocks[user].push(UserLock({
            amount: amount,
            unlockTime: unlockTime
        }));
        lockedBalance[user] += amount;
    }


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


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);

        if (from != address(0) && to != address(0)) {
            uint256 totalBalance = balanceOf(from);


            uint256 currentAvailable = totalBalance > lockedBalance[from] ? totalBalance - lockedBalance[from] : 0;


            if (currentAvailable >= amount) {
                return;
            }


            _cleanExpired(from);
            uint256 finalAvailable = totalBalance > lockedBalance[from] ? totalBalance - lockedBalance[from] : 0;


            require(finalAvailable >= amount, "Tokens locked");
        }
    }


    function claimRewards() external onlyOperator {
        require(voter != address(0), "Voter not set");
        require(rewardsDistributor != address(0), "Distributor not set");


        uint256  rebaseAmount = IRewardsDistributor(rewardsDistributor).claim(veTokenId);
        rebase += rebaseAmount;

        address[] memory votedPools = IVoter(voter).poolVote(veTokenId);

        for (uint256 i = 0; i < votedPools.length; i++) {
            if (votedPools[i] != address(0)) {
                address gauge = IGaugeManager(gaugeManager).gauges(votedPools[i]);

                if (gauge != address(0)) {

                    address[] memory bribes = new address[](1);
                    address[][] memory tokens = new address[][](1);


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

                            IGaugeManager(gaugeManager).claimBribes(bribes, tokens, veTokenId);
                        }
                    }


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

                            IGaugeManager(gaugeManager).claimBribes(bribes, tokens, veTokenId);
                        }
                    }
                }
            }
        }
    }


    function executeSwap(ISwapper.SwapParams calldata _params) external nonReentrant onlyOperator {
        require(address(swapper) != address(0), "Swapper not set");


        uint256 tokenBalance = IERC20(_params.tokenIn).balanceOf(address(this));
        require(tokenBalance >= _params.amountIn, "Insufficient token balance");


        IERC20(_params.tokenIn).safeApprove(address(swapper), _params.amountIn);


        uint256 hybrReceived = swapper.swapToHYBR(_params);


        IERC20(_params.tokenIn).safeApprove(address(swapper), 0);


        votingYield += hybrReceived;
    }


    function compound() external onlyOperator {


        uint256 hybrBalance = IERC20(HYBR).balanceOf(address(this));

        if (hybrBalance > 0) {

            IERC20(HYBR).safeApprove(votingEscrow, hybrBalance);
            IVotingEscrow(votingEscrow).deposit_for(veTokenId, hybrBalance);


            _extendLockToMax();

            lastCompoundTime = block.timestamp;

            emit Compound(hybrBalance, totalAssets());
        }
    }


    function vote(address[] calldata _poolVote, uint256[] calldata _weights) external {
        require(msg.sender == owner() || msg.sender == operator, "Not authorized");
        require(voter != address(0), "Voter not set");

        IVoter(voter).vote(veTokenId, _poolVote, _weights);
        lastVoteEpoch = HybraTimeLibrary.epochStart(block.timestamp);

    }


    function reset() external {
        require(msg.sender == owner() || msg.sender == operator, "Not authorized");
        require(voter != address(0), "Voter not set");

        IVoter(voter).reset(veTokenId);
    }


    function receivePenaltyReward(uint256 amount) external {


        if (amount > 0) {
            IERC20(HYBR).approve(votingEscrow, amount);

            if(veTokenId == 0){
                _initializeVeNFT(amount);
            } else{
                IVotingEscrow(votingEscrow).deposit_for(veTokenId, amount);


                _extendLockToMax();
            }
        }
        penalty += amount;
        emit PenaltyRewardReceived(amount);
    }


    function setVoter(address _voter) external onlyOwner {
        require(_voter != address(0), "Invalid voter");
        voter = _voter;
        emit VoterSet(_voter);
    }


    function setTransferLockPeriod(uint256 _period) external onlyOwner {
        require(_period >= MIN_LOCK_PERIOD && _period <= MAX_LOCK_PERIOD, "Invalid period");
        uint256 oldPeriod = transferLockPeriod;
        transferLockPeriod = _period;
        emit TransferLockPeriodUpdated(oldPeriod, _period);
    }


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


    function setSwapper(address _swapper) external onlyOwner {
        require(_swapper != address(0), "Invalid swapper");
        address oldSwapper = address(swapper);
        swapper = ISwapper(_swapper);
        emit SwapperUpdated(oldSwapper, _swapper);
    }


    function setTeam(address _team) external onlyOwner {
        require(_team != address(0), "Invalid team");
        Team = _team;
    }


    function emergencyUnlock(address user) external onlyOperator {
        delete userLocks[user];
        lockedBalance[user] = 0;
        emit EmergencyUnlock(user);
    }


    function getUserLocks(address user) external view returns (UserLock[] memory) {
        return userLocks[user];
    }


    function setOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "Invalid operator");
        address oldOperator = operator;
        operator = _operator;
        emit OperatorUpdated(oldOperator, _operator);
    }


    function getLockEndTime() external view returns (uint256) {
        if (veTokenId == 0) {
            return 0;
        }
        IVotingEscrow.LockedBalance memory locked = IVotingEscrow(votingEscrow).locked(veTokenId);
        return uint256(locked.end);
    }


    function _extendLockToMax() internal {
        if (veTokenId == 0) return;

        IVotingEscrow.LockedBalance memory locked = IVotingEscrow(votingEscrow).locked(veTokenId);
        if (locked.isPermanent || locked.end <= block.timestamp) return;

        uint256 maxUnlockTime = ((block.timestamp + HybraTimeLibrary.MAX_LOCK_DURATION) / HybraTimeLibrary.WEEK) * HybraTimeLibrary.WEEK;


        if (maxUnlockTime > locked.end + 2 hours) {
            try IVotingEscrow(votingEscrow).increase_unlock_time(veTokenId, HybraTimeLibrary.MAX_LOCK_DURATION) {

            } catch {


            }
        }
    }


    // Unified dispatcher - merged from: claimRewards, setRewardsDistributor, setGaugeManager
    // Selectors: claimRewards=0, setRewardsDistributor=1, setGaugeManager=2
    function execute(uint8 _selector, address _gaugeManager, address _rewardsDistributor) public {
        // Original: claimRewards()
        if (_selector == 0) {
            require(voter != address(0), "Voter not set");
            require(rewardsDistributor != address(0), "Distributor not set");
            uint256  rebaseAmount = IRewardsDistributor(rewardsDistributor).claim(veTokenId);
            rebase += rebaseAmount;
            address[] memory votedPools = IVoter(voter).poolVote(veTokenId);
            for (uint256 i = 0; i < votedPools.length; i++) {
            if (votedPools[i] != address(0)) {
            address gauge = IGaugeManager(gaugeManager).gauges(votedPools[i]);
            if (gauge != address(0)) {
            address[] memory bribes = new address[](1);
            address[][] memory tokens = new address[][](1);
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
            IGaugeManager(gaugeManager).claimBribes(bribes, tokens, veTokenId);
            }
            }
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
            IGaugeManager(gaugeManager).claimBribes(bribes, tokens, veTokenId);
            }
            }
            }
            }
            }
        }
        // Original: setRewardsDistributor()
        else if (_selector == 1) {
            require(_rewardsDistributor != address(0), "Invalid rewards distributor");
            rewardsDistributor = _rewardsDistributor;
        }
        // Original: setGaugeManager()
        else if (_selector == 2) {
            require(_gaugeManager != address(0), "Invalid gauge manager");
            gaugeManager = _gaugeManager;
        }
    }
}