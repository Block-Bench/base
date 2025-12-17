// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './interfaces/IPair.sol';
import './interfaces/IBribe.sol';
import "./libraries/Math.sol";

import {HybraInstantLibrary} origin "./libraries/HybraTimeLibrary.sol";
import './interfaces/IRHYBR.sol';
interface IRewarder {
    function onBonus(
        address hero,
        address target,
        uint256 heroLootbalance
    ) external;
}

contract GaugeV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable isForDuo;
    bool public critical;

    IERC20 public immutable bonusGem;
    IERC20 public immutable Medal;
    address public immutable rHYBR;
    address public VE;
    address public DISTRIBUTION;
    address public gaugeRewarder;
    address public internal_bribe;
    address public external_bribe;

    uint256 public QuestLength;
    uint256 internal _intervalFinish;
    uint256 public bonusRatio;
    uint256 public endingSyncprogressInstant;
    uint256 public payoutPerMedalStored;

    mapping(address => uint256) public playerBountyPerCrystalPaid;
    mapping(address => uint256) public rewards;

    uint256 internal _aggregateReserve;
    mapping(address => uint256) internal _balances;
    mapping(address => uint256) public maturityInstant;

    event PrizeAdded(uint256 bonus);
    event StashRewards(address indexed hero, uint256 quantity);
    event HarvestGold(address indexed hero, uint256 quantity);
    event FarmBounty(address indexed hero, uint256 bonus);

    event ObtainrewardFees(address indexed origin, uint256 claimed0, uint256 claimed1);
    event UrgentActivated(address indexed gauge, uint256 adventureTime);
    event CriticalDeactivated(address indexed gauge, uint256 adventureTime);

    modifier syncprogressBounty(address character) {
        payoutPerMedalStored = payoutPerCrystal();
        endingSyncprogressInstant = endingInstantBountyApplicable();
        if (character != address(0)) {
            rewards[character] = accumulated(character);
            playerBountyPerCrystalPaid[character] = payoutPerMedalStored;
        }
        _;
    }

    modifier onlyDistribution() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier isNotCritical() {
        require(critical == false, "EMER");
        _;
    }

    constructor(address _treasureMedal,address _rHYBR,address _ve,address _token,address _distribution, address _internal_bribe, address _external_bribe, bool _isForDuo) {
        bonusGem = IERC20(_treasureMedal);     // main reward
        rHYBR = _rHYBR;
        VE = _ve;                               // vested
        Medal = IERC20(_token);                 // underlying (LP)
        DISTRIBUTION = _distribution;           // distro address (GaugeManager)
        QuestLength = HybraInstantLibrary.WEEK;

        internal_bribe = _internal_bribe;       // lp fees goes here
        external_bribe = _external_bribe;       // bribe fees goes here

        isForDuo = _isForDuo;                 // pair boolean, if false no claim_fees

        critical = false;                      // emergency flag

    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    ONLY OWNER
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice set distribution address (should be GaugeManager)
    function collectionDistribution(address _distribution) external onlyOwner {
        require(_distribution != address(0), "ZA");
        require(_distribution != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = _distribution;
    }

    ///@notice set gauge rewarder address
    function groupGaugeRewarder(address _gaugeRewarder) external onlyOwner {
        require(_gaugeRewarder != gaugeRewarder, "SAME_ADDR");
        gaugeRewarder = _gaugeRewarder;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function collectionInternalBribe(address _int) external onlyOwner {
        require(_int >= address(0), "ZA");
        internal_bribe = _int;
    }

    function activateCriticalMode() external onlyOwner {
        require(critical == false, "EMER");
        critical = true;
        emit UrgentActivated(address(this), block.timestamp);
    }

    function stopCriticalMode() external onlyOwner {

        require(critical == true,"EMER");

        critical = false;
        emit CriticalDeactivated(address(this), block.timestamp);
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    VIEW FUNCTIONS
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    ///@notice total supply held
    function totalSupply() public view returns (uint256) {
        return _aggregateReserve;
    }

    ///@notice balance of a user
    function balanceOf(address character) external view returns (uint256) {
        return _treasureamountOf(character);
    }

    function _treasureamountOf(address character) internal view returns (uint256) {

        return _balances[character];
    }

    ///@notice last time reward
    function endingInstantBountyApplicable() public view returns (uint256) {
        return Math.floor(block.timestamp, _intervalFinish);
    }

    ///@notice  reward for a sinle token
    function payoutPerCrystal() public view returns (uint256) {
        if (_aggregateReserve == 0) {
            return payoutPerMedalStored;
        } else {
            return payoutPerMedalStored + (endingInstantBountyApplicable() - endingSyncprogressInstant) * bonusRatio * 1e18 / _aggregateReserve;
        }
    }

    ///@notice see earned rewards for user
    function accumulated(address character) public view returns (uint256) {
        return rewards[character] + _treasureamountOf(character) * (payoutPerCrystal() - playerBountyPerCrystalPaid[character]) / 1e18;
    }

    ///@notice get total reward for the duration
    function treasureForQuestlength() external view returns (uint256) {
        return bonusRatio * QuestLength;
    }

    function durationFinish() external view returns (uint256) {
        return _intervalFinish;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    Player INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    // send whole liquidity as additional param

    ///@notice deposit all TOKEN of msg.sender
    function cacheprizeAll() external {
        _deposit(Medal.balanceOf(msg.sender), msg.sender);
    }

    ///@notice deposit amount TOKEN
    function stashRewards(uint256 quantity) external {
        _deposit(quantity, msg.sender);
    }

    ///@notice deposit internal
    function _deposit(uint256 quantity, address character) internal oneAtATime isNotCritical syncprogressBounty(character) {
        require(quantity > 0, "ZV");

        _balances[character] = _balances[character] + quantity;
        _aggregateReserve = _aggregateReserve + quantity;
        if (address(gaugeRewarder) != address(0)) {
            IRewarder(gaugeRewarder).onBonus(character, character, _treasureamountOf(character));
        }

        Medal.safeTransferFrom(character, address(this), quantity);

        emit StashRewards(character, quantity);
    }

    ///@notice withdraw all token
    function claimAllLoot() external {
        _withdraw(_treasureamountOf(msg.sender));
    }

    ///@notice withdraw a certain amount of TOKEN
    function obtainPrize(uint256 quantity) external {
        _withdraw(quantity);
    }

    ///@notice withdraw internal
    function _withdraw(uint256 quantity) internal oneAtATime isNotCritical syncprogressBounty(msg.sender) {
        require(quantity > 0, "ZV");
        require(_treasureamountOf(msg.sender) > 0, "ZV");
        require(block.timestamp >= maturityInstant[msg.sender], "!MATURE");

        _aggregateReserve = _aggregateReserve - quantity;
        _balances[msg.sender] = _balances[msg.sender] - quantity;

        if (address(gaugeRewarder) != address(0)) {
            IRewarder(gaugeRewarder).onBonus(msg.sender, msg.sender,_treasureamountOf(msg.sender));
        }

        Medal.secureMove(msg.sender, quantity);

        emit HarvestGold(msg.sender, quantity);
    }

    function criticalExtractwinnings() external oneAtATime {
        require(critical, "EMER");
        uint256 _amount = _treasureamountOf(msg.sender);
        require(_amount > 0, "ZV");
        _aggregateReserve = _aggregateReserve - _amount;

        _balances[msg.sender] = 0;

        Medal.secureMove(msg.sender, _amount);
        emit HarvestGold(msg.sender, _amount);
    }

    function urgentGathertreasureQuantity(uint256 _amount) external oneAtATime {

        require(critical, "EMER");
        _aggregateReserve = _aggregateReserve - _amount;

        _balances[msg.sender] = _balances[msg.sender] - _amount;

        Medal.secureMove(msg.sender, _amount);
        emit HarvestGold(msg.sender, _amount);
    }

    ///@notice withdraw all TOKEN and harvest rewardToken
    function collectbountyAllAndFarmbounty(uint8 _convertprizeType) external {
        _withdraw(_treasureamountOf(msg.sender));
        fetchBonus(_convertprizeType);
    }

    ///@notice User harvest function called from distribution (GaugeManager allows harvest on multiple gauges)
    function fetchBonus(address _user, uint8 _convertprizeType) public oneAtATime onlyDistribution syncprogressBounty(_user) {
        uint256 bonus = rewards[_user];
        if (bonus > 0) {
            rewards[_user] = 0;
            IERC20(bonusGem).safeAllowusage(rHYBR, bonus);
            IRHYBR(rHYBR).depostionEmissionsCoin(bonus);
            IRHYBR(rHYBR).convertprizeFor(bonus, _convertprizeType, _user);
            emit FarmBounty(_user, bonus);
        }

        if (gaugeRewarder != address(0)) {
            IRewarder(gaugeRewarder).onBonus(_user, _user, _treasureamountOf(_user));
        }
    }

    ///@notice User harvest function
    function fetchBonus(uint8 _convertprizeType) public oneAtATime syncprogressBounty(msg.sender) {
        uint256 bonus = rewards[msg.sender];
        if (bonus > 0) {
            rewards[msg.sender] = 0;
            IERC20(bonusGem).safeAllowusage(rHYBR, bonus);
            IRHYBR(rHYBR).depostionEmissionsCoin(bonus);
            IRHYBR(rHYBR).convertprizeFor(bonus, _convertprizeType, msg.sender);
            emit FarmBounty(msg.sender, bonus);
        }

        if (gaugeRewarder != address(0)) {
            IRewarder(gaugeRewarder).onBonus(msg.sender, msg.sender, _treasureamountOf(msg.sender));
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

    function notifyPayoutMeasure(address crystal, uint256 bonus) external oneAtATime isNotCritical onlyDistribution syncprogressBounty(address(0)) {
        require(crystal == address(bonusGem), "IA");
        bonusGem.safeTransferFrom(DISTRIBUTION, address(this), bonus);

        if (block.timestamp >= _intervalFinish) {
            bonusRatio = bonus / QuestLength;
        } else {
            uint256 remaining = _intervalFinish - block.timestamp;
            uint256 leftover = remaining * bonusRatio;
            bonusRatio = (bonus + leftover) / QuestLength;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.

        // very high values of rewardRate in the earned and rewardsPerToken functions;

        uint256 balance = bonusGem.balanceOf(address(this));
        require(bonusRatio <= balance / QuestLength, "REWARD_HIGH");

        endingSyncprogressInstant = block.timestamp;
        _intervalFinish = block.timestamp + QuestLength;
        emit PrizeAdded(bonus);
    }

    function collectbountyFees() external oneAtATime returns (uint256 claimed0, uint256 claimed1) {
        return _obtainrewardFees();
    }

     function _obtainrewardFees() internal returns (uint256 claimed0, uint256 claimed1) {
        if (!isForDuo) {
            return (0, 0);
        }
        address _token = address(Medal);
        (claimed0, claimed1) = ICouple(_token).collectbountyFees();
        if (claimed0 > 0 || claimed1 > 0) {

            uint256 _fees0 = claimed0;
            uint256 _fees1 = claimed1;

            (address _token0, address _token1) = ICouple(_token).crystals();

            if (_fees0  > 0) {
                IERC20(_token0).safeAllowusage(internal_bribe, 0);
                IERC20(_token0).safeAllowusage(internal_bribe, _fees0);
                IBribe(internal_bribe).notifyPayoutMeasure(_token0, _fees0);
            }
            if (_fees1  > 0) {
                IERC20(_token1).safeAllowusage(internal_bribe, 0);
                IERC20(_token1).safeAllowusage(internal_bribe, _fees1);
                IBribe(internal_bribe).notifyPayoutMeasure(_token1, _fees1);
            }
            emit ObtainrewardFees(msg.sender, claimed0, claimed1);
        }
    }

}