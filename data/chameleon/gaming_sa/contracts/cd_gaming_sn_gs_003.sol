// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './interfaces/IPair.sol';
import './interfaces/IBribe.sol';
import "./libraries/Math.sol";

import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import './interfaces/IRHYBR.sol';
interface IRewarder {
    function onVictorybonus(
        address hero,
        address recipient,
        uint256 gamerLootbalance
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable isForPair;
    bool public emergency;

    IERC20 public immutable lootrewardGamecoin;
    IERC20 public immutable GoldToken;
    address public immutable rHYBR;
    address public VE;
    address public DISTRIBUTION;
    address public gaugeRewarder;
    address public internal_bribe;
    address public external_bribe;

    uint256 public DURATION;
    uint256 internal _periodFinish;
    uint256 public victorybonusScoremultiplier;
    uint256 public lastUpdateTime;
    uint256 public lootrewardPerGoldtokenStored;

    mapping(address => uint256) public playerBattleprizePerGamecoinPaid;
    mapping(address => uint256) public rewards;

    uint256 internal _worldsupply;
    mapping(address => uint256) internal _balances;
    mapping(address => uint256) public maturityTime;

    event LootrewardAdded(uint256 questReward);
    event CacheTreasure(address indexed hero, uint256 amount);
    event TakePrize(address indexed hero, uint256 amount);
    event Harvest(address indexed hero, uint256 questReward);

    event EarnpointsFees(address indexed from, uint256 claimed0, uint256 claimed1);
    event EmergencyActivated(address indexed gauge, uint256 timestamp);
    event EmergencyDeactivated(address indexed gauge, uint256 timestamp);

    modifier updateLootreward(address playerAccount) {
        lootrewardPerGoldtokenStored = victorybonusPerQuesttoken();
        lastUpdateTime = lastTimeQuestrewardApplicable();
        if (playerAccount != address(0)) {
            rewards[playerAccount] = earned(playerAccount);
            playerBattleprizePerGamecoinPaid[playerAccount] = lootrewardPerGoldtokenStored;
        }
        _;
    }

    modifier onlyDistribution() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier isNotEmergency() {
        require(emergency == false, "EMER");
        _;
    }

    constructor(address _rewardToken,address _rHYBR,address _ve,address _questtoken,address _distribution, address _internal_bribe, address _external_bribe, bool _isForPair) {
        lootrewardGamecoin = IERC20(_rewardToken);     // main reward
        rHYBR = _rHYBR;
        VE = _ve;                               // vested
        GoldToken = IERC20(_questtoken);                 // underlying (LP)
        DISTRIBUTION = _distribution;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        internal_bribe = _internal_bribe;       // lp fees goes here
        external_bribe = _external_bribe;       // bribe fees goes here

        isForPair = _isForPair;                 // pair boolean, if false no claim_fees

        emergency = false;                      // emergency flag

    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    ONLY OWNER
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice set distribution address (should be GaugeManager)
    function setDistribution(address _distribution) external onlyGamemaster {
        require(_distribution != address(0), "ZA");
        require(_distribution != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = _distribution;
    }

    ///@notice set gauge rewarder address
    function setGaugeRewarder(address _gaugeRewarder) external onlyGamemaster {
        require(_gaugeRewarder != gaugeRewarder, "SAME_ADDR");
        gaugeRewarder = _gaugeRewarder;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function setInternalBribe(address _int) external onlyGamemaster {
        require(_int >= address(0), "ZA");
        internal_bribe = _int;
    }

    function activateEmergencyMode() external onlyGamemaster {
        require(emergency == false, "EMER");
        emergency = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function stopEmergencyMode() external onlyGamemaster {

        require(emergency == true,"EMER");

        emergency = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    VIEW FUNCTIONS
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice total supply held
    function worldSupply() public view returns (uint256) {
        return _worldsupply;
    }

    ///@notice balance of a user
    function goldholdingOf(address playerAccount) external view returns (uint256) {
        return _balanceOf(playerAccount);
    }

    function _balanceOf(address playerAccount) internal view returns (uint256) {

        return _balances[playerAccount];
    }

    ///@notice last time reward
    function lastTimeQuestrewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, _periodFinish);
    }

    ///@notice  reward for a sinle token
    function victorybonusPerQuesttoken() public view returns (uint256) {
        if (_worldsupply == 0) {
            return lootrewardPerGoldtokenStored;
        } else {
            return lootrewardPerGoldtokenStored + (lastTimeQuestrewardApplicable() - lastUpdateTime) * victorybonusScoremultiplier * 1e18 / _worldsupply;
        }
    }

    ///@notice see earned rewards for user
    function earned(address playerAccount) public view returns (uint256) {
        return rewards[playerAccount] + _balanceOf(playerAccount) * (victorybonusPerQuesttoken() - playerBattleprizePerGamecoinPaid[playerAccount]) / 1e18;
    }

    ///@notice get total reward for the duration
    function victorybonusForDuration() external view returns (uint256) {
        return victorybonusScoremultiplier * DURATION;
    }

    function periodFinish() external view returns (uint256) {
        return _periodFinish;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    USER INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    // send whole liquidity as additional param

    ///@notice deposit all TOKEN of msg.sender
    function cachetreasureAll() external {
        _saveprize(GoldToken.goldholdingOf(msg.sender), msg.sender);
    }

    ///@notice deposit amount TOKEN
    function stashItems(uint256 amount) external {
        _saveprize(amount, msg.sender);
    }

    ///@notice deposit internal
    function _saveprize(uint256 amount, address playerAccount) internal nonReentrant isNotEmergency updateLootreward(playerAccount) {
        require(amount > 0, "ZV");

        _balances[playerAccount] = _balances[playerAccount] + amount;
        _worldsupply = _worldsupply + amount;
        if (address(gaugeRewarder) != address(0)) {
            IRewarder(gaugeRewarder).onVictorybonus(playerAccount, playerAccount, _balanceOf(playerAccount));
        }

        GoldToken.safeSendgoldFrom(playerAccount, address(this), amount);

        emit CacheTreasure(playerAccount, amount);
    }

    ///@notice withdraw all token
    function claimlootAll() external {
        _redeemgold(_balanceOf(msg.sender));
    }

    ///@notice withdraw a certain amount of TOKEN
    function collectTreasure(uint256 amount) external {
        _redeemgold(amount);
    }

    ///@notice withdraw internal
    function _redeemgold(uint256 amount) internal nonReentrant isNotEmergency updateLootreward(msg.sender) {
        require(amount > 0, "ZV");
        require(_balanceOf(msg.sender) > 0, "ZV");
        require(block.timestamp >= maturityTime[msg.sender], "!MATURE");

        _worldsupply = _worldsupply - amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;

        if (address(gaugeRewarder) != address(0)) {
            IRewarder(gaugeRewarder).onVictorybonus(msg.sender, msg.sender,_balanceOf(msg.sender));
        }

        GoldToken.safeSendgold(msg.sender, amount);

        emit TakePrize(msg.sender, amount);
    }

    function emergencyClaimloot() external nonReentrant {
        require(emergency, "EMER");
        uint256 _amount = _balanceOf(msg.sender);
        require(_amount > 0, "ZV");
        _worldsupply = _worldsupply - _amount;

        _balances[msg.sender] = 0;

        GoldToken.safeSendgold(msg.sender, _amount);
        emit TakePrize(msg.sender, _amount);
    }

    function emergencyClaimlootAmount(uint256 _amount) external nonReentrant {

        require(emergency, "EMER");
        _worldsupply = _worldsupply - _amount;

        _balances[msg.sender] = _balances[msg.sender] - _amount;

        GoldToken.safeSendgold(msg.sender, _amount);
        emit TakePrize(msg.sender, _amount);
    }

    ///@notice withdraw all TOKEN and harvest rewardToken
    function collecttreasureAllAndHarvest(uint8 _redeemType) external {
        _redeemgold(_balanceOf(msg.sender));
        getLootreward(_redeemType);
    }

    ///@notice User harvest function called from distribution (GaugeManager allows harvest on multiple gauges)
    function getLootreward(address _player, uint8 _redeemType) public nonReentrant onlyDistribution updateLootreward(_player) {
        uint256 questReward = rewards[_player];
        if (questReward > 0) {
            rewards[_player] = 0;
            IERC20(lootrewardGamecoin).safeAllowtransfer(rHYBR, questReward);
            IRHYBR(rHYBR).depostionEmissionsRealmcoin(questReward);
            IRHYBR(rHYBR).redeemFor(questReward, _redeemType, _player);
            emit Harvest(_player, questReward);
        }

        if (gaugeRewarder != address(0)) {
            IRewarder(gaugeRewarder).onVictorybonus(_player, _player, _balanceOf(_player));
        }
    }

    ///@notice User harvest function
    function getLootreward(uint8 _redeemType) public nonReentrant updateLootreward(msg.sender) {
        uint256 questReward = rewards[msg.sender];
        if (questReward > 0) {
            rewards[msg.sender] = 0;
            IERC20(lootrewardGamecoin).safeAllowtransfer(rHYBR, questReward);
            IRHYBR(rHYBR).depostionEmissionsRealmcoin(questReward);
            IRHYBR(rHYBR).redeemFor(questReward, _redeemType, msg.sender);
            emit Harvest(msg.sender, questReward);
        }

        if (gaugeRewarder != address(0)) {
            IRewarder(gaugeRewarder).onVictorybonus(msg.sender, msg.sender, _balanceOf(msg.sender));
        }
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    DISTRIBUTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @dev Receive rewards from distribution

    function notifyQuestrewardAmount(address goldToken, uint256 questReward) external nonReentrant isNotEmergency onlyDistribution updateLootreward(address(0)) {
        require(goldToken == address(lootrewardGamecoin), "IA");
        lootrewardGamecoin.safeSendgoldFrom(DISTRIBUTION, address(this), questReward);

        if (block.timestamp >= _periodFinish) {
            victorybonusScoremultiplier = questReward / DURATION;
        } else {
            uint256 remaining = _periodFinish - block.timestamp;
            uint256 leftover = remaining * victorybonusScoremultiplier;
            victorybonusScoremultiplier = (questReward + leftover) / DURATION;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.

        // very high values of rewardRate in the earned and rewardsPerToken functions;

        uint256 goldHolding = lootrewardGamecoin.goldholdingOf(address(this));
        require(victorybonusScoremultiplier <= goldHolding / DURATION, "REWARD_HIGH");

        lastUpdateTime = block.timestamp;
        _periodFinish = block.timestamp + DURATION;
        emit LootrewardAdded(questReward);
    }

    function collectrewardFees() external nonReentrant returns (uint256 claimed0, uint256 claimed1) {
        return _claimFees();
    }

     function _claimFees() internal returns (uint256 claimed0, uint256 claimed1) {
        if (!isForPair) {
            return (0, 0);
        }
        address _questtoken = address(GoldToken);
        (claimed0, claimed1) = IPair(_questtoken).collectrewardFees();
        if (claimed0 > 0 || claimed1 > 0) {

            uint256 _fees0 = claimed0;
            uint256 _fees1 = claimed1;

            (address _token0, address _token1) = IPair(_questtoken).tokens();

            if (_fees0  > 0) {
                IERC20(_token0).safeAllowtransfer(internal_bribe, 0);
                IERC20(_token0).safeAllowtransfer(internal_bribe, _fees0);
                IBribe(internal_bribe).notifyQuestrewardAmount(_token0, _fees0);
            }
            if (_fees1  > 0) {
                IERC20(_token1).safeAllowtransfer(internal_bribe, 0);
                IERC20(_token1).safeAllowtransfer(internal_bribe, _fees1);
                IBribe(internal_bribe).notifyQuestrewardAmount(_token1, _fees1);
            }
            emit EarnpointsFees(msg.sender, claimed0, claimed1);
        }
    }

}