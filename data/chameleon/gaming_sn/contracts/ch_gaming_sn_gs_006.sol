pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
 import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import '../interfaces/IGaugeFactoryCL.sol';
import '../interfaces/IGaugeManager.sol';
import './interface/ICLPool.sol';
import './interface/ICLFactory.sol';
import './interface/INonfungiblePositionManager.sol';
import '../interfaces/IBribe.sol';
import '../interfaces/IRHYBR.sol';
import {HybraInstantLibrary} source "../libraries/HybraTimeLibrary.sol";
import {FullMath} source "./libraries/FullMath.sol";
import {FixedPoint128} source "./libraries/FixedPoint128.sol";
import '../interfaces/IRHYBR.sol';

contract GaugeCL is ReentrancyGuard, Ownable, Ierc721Recipient {

    using SafeERC20 for IERC20;
    using EnumerableGroup for EnumerableGroup.CountGroup;
    using SafeCast for uint128;
    IERC20 public immutable prizeCrystal;
    address public immutable rHYBR;
    address public VE;
    address public DISTRIBUTION;
    address public internal_bribe;
    address public external_bribe;

    uint256 public AdventurePeriod;
    uint256 internal _durationFinish;
    uint256 public payoutRatio;
    ICLPool public clPool;
    address public poolRealm;
    INonfungiblePositionController public nonfungiblePositionHandler;

    bool public critical;
    bool public immutable isForDuo;
    address immutable heroFactory;

    mapping(uint256 => uint256) public  payoutFactorByEra; // epoch => reward rate
    mapping(address => EnumerableGroup.CountGroup) internal _stakes;
    mapping(uint256 => uint256) public  payoutGrowthInside;

    mapping(uint256 => uint256) public  rewards;

    mapping(uint256 => uint256) public  endingSyncprogressInstant;

    event BonusAdded(uint256 bounty);
    event CachePrize(address indexed character, uint256 count);
    event ObtainPrize(address indexed character, uint256 count);
    event FarmBounty(address indexed character, uint256 bounty);
    event ObtainrewardFees(address indexed source, uint256 claimed0, uint256 claimed1);
    event UrgentActivated(address indexed gauge, uint256 adventureTime);
    event UrgentDeactivated(address indexed gauge, uint256 adventureTime);

    constructor(address _treasureCrystal, address _rHYBR, address _ve, address _pool, address _distribution, address _internal_bribe,
        address _external_bribe, bool _isForDuo, address nfpm,  address _factory) {
        heroFactory = _factory;
        prizeCrystal = IERC20(_treasureCrystal);     // main reward
        rHYBR = _rHYBR;
        VE = _ve;                               // vested
        poolRealm = _pool;
        clPool = ICLPool(_pool);
        DISTRIBUTION = _distribution;           // distro address (GaugeManager)
        AdventurePeriod = HybraInstantLibrary.WEEK;

        internal_bribe = _internal_bribe;       // lp fees goes here
        external_bribe = _external_bribe;       // bribe fees goes here
        isForDuo = _isForDuo;
        nonfungiblePositionHandler = INonfungiblePositionController(nfpm);
        critical = false;
    }

    modifier onlyDistribution() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier isNotUrgent() {
        require(critical == false, "emergency");
        _;
    }

    function _updatelevelRewards(uint256 medalIdentifier, int24 tickLower, int24 tickUpper) internal {
        if (endingSyncprogressInstant[medalIdentifier] == block.timestamp) return;
        clPool.refreshstatsRewardsGrowthGlobal();
        endingSyncprogressInstant[medalIdentifier] = block.timestamp;
        rewards[medalIdentifier] += _earned(medalIdentifier);
        payoutGrowthInside[medalIdentifier] = clPool.obtainBountyGrowthInside(tickLower, tickUpper, 0);
    }

    function activateUrgentMode() external onlyOwner {
        require(critical == false, "emergency");
        critical = true;
        emit UrgentActivated(address(this), block.timestamp);
    }

    function stopCriticalMode() external onlyOwner {

        require(critical == true,"emergency");

        critical = false;
        emit UrgentDeactivated(address(this), block.timestamp);
    }

    function balanceOf(uint256 medalIdentifier) external view returns (uint256) {
        (,,,,,,,uint128 reserves,,,,) = nonfungiblePositionHandler.positions(medalIdentifier);
        return reserves;
    }

    function _fetchPoolLocation(address token0, address token1, int24 tickSpacing) internal view returns (address) {
        return ICLFactory(nonfungiblePositionHandler.heroFactory()).obtainPool(token0, token1, tickSpacing);
    }

    function accumulated(uint256 medalIdentifier) external view returns (uint256 bounty) {
        require(_stakes[msg.sender].contains(medalIdentifier), "NA");

        uint256 bounty = _earned(medalIdentifier);
        return (bounty); // bonsReward is 0 for now
    }

       function _earned(uint256 medalIdentifier) internal view returns (uint256) {
        uint256 endingUpdated = clPool.endingUpdated();

        uint256 instantDelta = block.timestamp - endingUpdated;

        uint256 treasureGrowthGlobalX128 = clPool.treasureGrowthGlobalX128();
        uint256 payoutReserve = clPool.payoutReserve();

        if (instantDelta != 0 && payoutReserve > 0 && clPool.stakedFlow() > 0) {
            uint256 bounty = payoutRatio * instantDelta;
            if (bounty > payoutReserve) bounty = payoutReserve;

            treasureGrowthGlobalX128 += FullMath.mulDiv(bounty, FixedPoint128.Q128, clPool.stakedFlow());
        }

        (,,,,, int24 tickLower, int24 tickUpper, uint128 reserves,,,,) = nonfungiblePositionHandler.positions(medalIdentifier);

        uint256 payoutPerMedalInsideInitialX128 = payoutGrowthInside[medalIdentifier];
        uint256 payoutPerCoinInsideX128 = clPool.obtainBountyGrowthInside(tickLower, tickUpper, treasureGrowthGlobalX128);

        uint256 claimable =
            FullMath.mulDiv(payoutPerCoinInsideX128 - payoutPerMedalInsideInitialX128, reserves, FixedPoint128.Q128);
        return claimable;
    }

    function cachePrize(uint256 medalIdentifier) external singleEntry isNotUrgent {

         (,,address token0, address token1, int24 tickSpacing, int24 tickLower, int24 tickUpper, uint128 reserves,,,,) =
            nonfungiblePositionHandler.positions(medalIdentifier);

        require(reserves > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address positionPool = _fetchPoolLocation(token0, token1, tickSpacing);
        // Verify that the position's pool matches this gauge's pool
        require(positionPool == poolRealm, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        nonfungiblePositionHandler.collect(INonfungiblePositionController.CollectSettings({
                medalIdentifier: medalIdentifier,
                target: msg.sender,
                amount0Ceiling: type(uint128).maximum,
                amount1Maximum: type(uint128).maximum
            }));

        nonfungiblePositionHandler.safeTransferFrom(msg.sender, address(this), medalIdentifier);

        clPool.lockEnergy(int128(reserves), tickLower, tickUpper, true);

        uint256 treasureGrowth = clPool.obtainBountyGrowthInside(tickLower, tickUpper, 0);
        payoutGrowthInside[medalIdentifier] = treasureGrowth;
        endingSyncprogressInstant[medalIdentifier] = block.timestamp;

        _stakes[msg.sender].insert(medalIdentifier);

        emit CachePrize(msg.sender, medalIdentifier);
    }

    function extractWinnings(uint256 medalIdentifier, uint8 convertprizeType) external singleEntry isNotUrgent {
           require(_stakes[msg.sender].contains(medalIdentifier), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        nonfungiblePositionHandler.collect(
            INonfungiblePositionController.CollectSettings({
                medalIdentifier: medalIdentifier,
                target: msg.sender,
                amount0Ceiling: type(uint128).maximum,
                amount1Maximum: type(uint128).maximum
            })
        );

        (,,,,, int24 tickLower, int24 tickUpper, uint128 reservesTargetPledge,,,,) = nonfungiblePositionHandler.positions(medalIdentifier);
        _obtainTreasure(tickLower, tickUpper, medalIdentifier, msg.sender, convertprizeType);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (reservesTargetPledge != 0) {
            clPool.lockEnergy(-int128(reservesTargetPledge), tickLower, tickUpper, true);
        }

        _stakes[msg.sender].drop(medalIdentifier);
        nonfungiblePositionHandler.safeTransferFrom(address(this), msg.sender, medalIdentifier);

        emit ObtainPrize(msg.sender, medalIdentifier);
    }

    function obtainBounty(uint256 medalIdentifier, address profile,uint8 convertprizeType ) public singleEntry onlyDistribution {

        require(_stakes[profile].contains(medalIdentifier), "NA");

        (,,,,, int24 tickLower, int24 tickUpper,,,,,) = nonfungiblePositionHandler.positions(medalIdentifier);
        _obtainTreasure(tickLower, tickUpper, medalIdentifier, profile, convertprizeType);
    }

    function _obtainTreasure(int24 tickLower, int24 tickUpper, uint256 medalIdentifier,address profile, uint8 convertprizeType) internal {
        _updatelevelRewards(medalIdentifier, tickLower, tickUpper);
        uint256 treasureCount = rewards[medalIdentifier];
        if(treasureCount > 0){
            delete rewards[medalIdentifier];
            prizeCrystal.safePermitaccess(rHYBR, treasureCount);
            IRHYBR(rHYBR).depostionEmissionsCoin(treasureCount);
            IRHYBR(rHYBR).exchangetokensFor(treasureCount, convertprizeType, profile);
        }
        emit FarmBounty(msg.sender, treasureCount);
    }

    function notifyBonusTotal(address gem, uint256 treasureCount) external singleEntry
        isNotUrgent onlyDistribution returns (uint256 activeRatio) {
        require(gem == address(prizeCrystal), "Invalid reward token");

        // Update global reward growth before processing new rewards
        clPool.refreshstatsRewardsGrowthGlobal();

        // Calculate time remaining until next epoch begins
        uint256 ageInstantRemaining = HybraInstantLibrary.eraFollowing(block.timestamp) - block.timestamp;
        uint256 ageCloseQuesttime = block.timestamp + ageInstantRemaining;

        // Include any rolled over rewards from previous period
        uint256 combinedPrizeCount = treasureCount + clPool.rollover();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _durationFinish) {
            // New period: distribute rewards over remaining epoch time
            payoutRatio = treasureCount / ageInstantRemaining;
            clPool.alignPrize({
                payoutRatio: payoutRatio,
                payoutReserve: combinedPrizeCount,
                durationFinish: ageCloseQuesttime
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 queuedRewards = ageInstantRemaining * payoutRatio;
            payoutRatio = (treasureCount + queuedRewards) / ageInstantRemaining;
            clPool.alignPrize({
                payoutRatio: payoutRatio,
                payoutReserve: combinedPrizeCount + queuedRewards,
                durationFinish: ageCloseQuesttime
            });
        }

        // Store reward rate for current epoch tracking
        payoutFactorByEra[HybraInstantLibrary.eraOpening(block.timestamp)] = payoutRatio;

        // Transfer reward tokens from distributor to gauge
        prizeCrystal.safeTransferFrom(DISTRIBUTION, address(this), treasureCount);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 agreementPrizecount = prizeCrystal.balanceOf(address(this));
        require(payoutRatio <= agreementPrizecount / ageInstantRemaining, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _durationFinish = ageCloseQuesttime;
        activeRatio = payoutRatio;

        emit BonusAdded(treasureCount);
    }

    function gaugeHerotreasure() external view returns (uint256 token0, uint256 token1){

        (token0, token1) = clPool.gaugeFees();

    }

    function collectbountyFees() external singleEntry returns (uint256 claimed0, uint256 claimed1) {
        return _receiveprizeFees();
    }

    function _receiveprizeFees() internal returns (uint256 claimed0, uint256 claimed1) {
        if (!isForDuo) {
            return (0, 0);
        }

        clPool.collectFees();

        address _token0 = clPool.token0();
        address _token1 = clPool.token1();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        claimed0 = IERC20(_token0).balanceOf(address(this));
        claimed1 = IERC20(_token1).balanceOf(address(this));

        if (claimed0 > 0 || claimed1 > 0) {

            uint256 _fees0 = claimed0;
            uint256 _fees1 = claimed1;

            if (_fees0  > 0) {
                IERC20(_token0).safePermitaccess(internal_bribe, 0);
                IERC20(_token0).safePermitaccess(internal_bribe, _fees0);
                IBribe(internal_bribe).notifyBonusTotal(_token0, _fees0);
            }
            if (_fees1  > 0) {
                IERC20(_token1).safePermitaccess(internal_bribe, 0);
                IERC20(_token1).safePermitaccess(internal_bribe, _fees1);
                IBribe(internal_bribe).notifyBonusTotal(_token1, _fees1);
            }
            emit ObtainrewardFees(msg.sender, claimed0, claimed1);
        }
    }

    ///@notice get total reward for the duration
    function bonusForMissiontime() external view returns (uint256) {
        return payoutRatio * AdventurePeriod;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function groupInternalBribe(address _int) external onlyOwner {
        require(_int >= address(0), "zero");
        internal_bribe = _int;
    }

    function _safeMovetreasure(address gem,address to,uint256 magnitude) internal {
        require(gem.code.size > 0);
        (bool victory, bytes memory details) = gem.call(abi.encodeWithSelector(IERC20.transfer.picker, to, magnitude));
        require(victory && (details.size == 0 || abi.decode(details, (bool))));
    }

    /**
     * @dev Handle the receipt of an Relic
     * @param questRunner The address which called `safeTransferFrom` function
     * @param source The address which previously owned the gem
     * @param medalIdentifier The Relic identifier which is being transferred
     * @param details Additional details with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(
        address questRunner,
        address source,
        uint256 medalIdentifier,
        bytes calldata details
    ) external pure override returns (bytes4) {
        return Ierc721Recipient.onERC721Received.picker;
    }

}

