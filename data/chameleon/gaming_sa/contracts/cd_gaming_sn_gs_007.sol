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
import {HybraTimeLibrary} from "../libraries/HybraTimeLibrary.sol";
import {FullMath} from "./libraries/FullMath.sol";
import {FixedPoint128} from "./libraries/FixedPoint128.sol";
import '../interfaces/IRHYBR.sol';

contract GaugeCL is ReentrancyGuard, Ownable, IERC721Receiver {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeCast for uint128;
    IERC20 public immutable victorybonusQuesttoken;
    address public immutable rHYBR;
    address public VE;
    address public DISTRIBUTION;
    address public internal_bribe;
    address public external_bribe;

    uint256 public DURATION;
    uint256 internal _periodFinish;
    uint256 public victorybonusBonusrate;
    IclLootpool public clPrizepool;
    address public lootpoolAddress;
    INonfungiblePositionManager public nonfungiblePositionManager;

    bool public emergency;
    bool public immutable isForPair;
    address immutable factory;

    mapping(uint256 => uint256) public  lootrewardBonusrateByEpoch; // epoch => reward rate
    mapping(address => EnumerableSet.UintSet) internal _stakes;
    mapping(uint256 => uint256) public  battleprizeGrowthInside;

    mapping(uint256 => uint256) public  rewards;

    mapping(uint256 => uint256) public  lastUpdateTime;

    event QuestrewardAdded(uint256 battlePrize);
    event StoreLoot(address indexed hero, uint256 amount);
    event ClaimLoot(address indexed hero, uint256 amount);
    event Harvest(address indexed hero, uint256 battlePrize);
    event GetbonusFees(address indexed from, uint256 claimed0, uint256 claimed1);
    event EmergencyActivated(address indexed gauge, uint256 timestamp);
    event EmergencyDeactivated(address indexed gauge, uint256 timestamp);

    constructor(address _rewardToken, address _rHYBR, address _ve, address _bountypool, address _distribution, address _internal_bribe,
        address _external_bribe, bool _isForPair, address nfpm,  address _factory) {
        factory = _factory;
        victorybonusQuesttoken = IERC20(_rewardToken);     // main reward
        rHYBR = _rHYBR;
        VE = _ve;                               // vested
        lootpoolAddress = _bountypool;
        clPrizepool = IclLootpool(_bountypool);
        DISTRIBUTION = _distribution;           // distro address (GaugeManager)
        DURATION = HybraTimeLibrary.WEEK;

        internal_bribe = _internal_bribe;       // lp fees goes here
        external_bribe = _external_bribe;       // bribe fees goes here
        isForPair = _isForPair;
        nonfungiblePositionManager = INonfungiblePositionManager(nfpm);
        emergency = false;
    }

    modifier onlyDistribution() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }

    modifier isNotEmergency() {
        require(emergency == false, "emergency");
        _;
    }

    function _updateRewards(uint256 gamecoinId, int24 tickLower, int24 tickUpper) internal {
        if (lastUpdateTime[gamecoinId] == block.timestamp) return;
        clPrizepool.updateRewardsGrowthGlobal();
        lastUpdateTime[gamecoinId] = block.timestamp;
        rewards[gamecoinId] += _earned(gamecoinId);
        battleprizeGrowthInside[gamecoinId] = clPrizepool.getVictorybonusGrowthInside(tickLower, tickUpper, 0);
    }

    function activateEmergencyMode() external onlyGamemaster {
        require(emergency == false, "emergency");
        emergency = true;
        emit EmergencyActivated(address(this), block.timestamp);
    }

    function stopEmergencyMode() external onlyGamemaster {

        require(emergency == true,"emergency");

        emergency = false;
        emit EmergencyDeactivated(address(this), block.timestamp);
    }

    function itemcountOf(uint256 gamecoinId) external view returns (uint256) {
        (,,,,,,,uint128 availableGold,,,,) = nonfungiblePositionManager.positions(gamecoinId);
        return availableGold;
    }

    function _getPoolAddress(address gamecoin0, address gamecoin1, int24 tickSpacing) internal view returns (address) {
        return ICLFactory(nonfungiblePositionManager.factory()).getLootpool(gamecoin0, gamecoin1, tickSpacing);
    }

    function earned(uint256 gamecoinId) external view returns (uint256 battlePrize) {
        require(_stakes[msg.sender].contains(gamecoinId), "NA");

        uint256 battlePrize = _earned(gamecoinId);
        return (battlePrize); // bonsReward is 0 for now
    }

       function _earned(uint256 gamecoinId) internal view returns (uint256) {
        uint256 lastUpdated = clPrizepool.lastUpdated();

        uint256 timeDelta = block.timestamp - lastUpdated;

        uint256 lootrewardGrowthGlobalX128 = clPrizepool.lootrewardGrowthGlobalX128();
        uint256 questrewardLootreserve = clPrizepool.questrewardLootreserve();

        if (timeDelta != 0 && questrewardLootreserve > 0 && clPrizepool.stakedFreeitems() > 0) {
            uint256 battlePrize = victorybonusBonusrate * timeDelta;
            if (battlePrize > questrewardLootreserve) battlePrize = questrewardLootreserve;

            lootrewardGrowthGlobalX128 += FullMath.mulDiv(battlePrize, FixedPoint128.Q128, clPrizepool.stakedFreeitems());
        }

        (,,,,, int24 tickLower, int24 tickUpper, uint128 availableGold,,,,) = nonfungiblePositionManager.positions(gamecoinId);

        uint256 battleprizePerRealmcoinInsideInitialX128 = battleprizeGrowthInside[gamecoinId];
        uint256 questrewardPerRealmcoinInsideX128 = clPrizepool.getVictorybonusGrowthInside(tickLower, tickUpper, lootrewardGrowthGlobalX128);

        uint256 claimable =
            FullMath.mulDiv(questrewardPerRealmcoinInsideX128 - battleprizePerRealmcoinInsideInitialX128, availableGold, FixedPoint128.Q128);
        return claimable;
    }

    function savePrize(uint256 gamecoinId) external nonReentrant isNotEmergency {

         (,,address gamecoin0, address gamecoin1, int24 tickSpacing, int24 tickLower, int24 tickUpper, uint128 availableGold,,,,) =
            nonfungiblePositionManager.positions(gamecoinId);

        require(availableGold > 0, "Gauge: zero liquidity");
        // Calculate pool address from position parameters
        address positionBountypool = _getPoolAddress(gamecoin0, gamecoin1, tickSpacing);
        // Verify that the position's pool matches this gauge's pool
        require(positionBountypool == lootpoolAddress, "Pool mismatch: Position not for this gauge pool");
        // collect fees
        nonfungiblePositionManager.collect(INonfungiblePositionManager.CollectParams({
                gamecoinId: gamecoinId,
                recipient: msg.sender,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            }));

        nonfungiblePositionManager.safeTradelootFrom(msg.sender, address(this), gamecoinId);

        clPrizepool.wagerTokens(int128(availableGold), tickLower, tickUpper, true);

        uint256 lootrewardGrowth = clPrizepool.getVictorybonusGrowthInside(tickLower, tickUpper, 0);
        battleprizeGrowthInside[gamecoinId] = lootrewardGrowth;
        lastUpdateTime[gamecoinId] = block.timestamp;

        _stakes[msg.sender].add(gamecoinId);

        emit StoreLoot(msg.sender, gamecoinId);
    }

    function redeemGold(uint256 gamecoinId, uint8 redeemType) external nonReentrant isNotEmergency {
           require(_stakes[msg.sender].contains(gamecoinId), "NA");

        // trigger update on staked position so NFT will be in sync with the pool
        nonfungiblePositionManager.collect(
            INonfungiblePositionManager.CollectParams({
                gamecoinId: gamecoinId,
                recipient: msg.sender,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        (,,,,, int24 tickLower, int24 tickUpper, uint128 tradableassetsToCommitgems,,,,) = nonfungiblePositionManager.positions(gamecoinId);
        _getReward(tickLower, tickUpper, gamecoinId, msg.sender, redeemType);

        // update virtual liquidity in pool only if token has existing liquidity
        // i.e. not all removed already via decreaseStakedLiquidity
        if (tradableassetsToCommitgems != 0) {
            clPrizepool.wagerTokens(-int128(tradableassetsToCommitgems), tickLower, tickUpper, true);
        }

        _stakes[msg.sender].remove(gamecoinId);
        nonfungiblePositionManager.safeTradelootFrom(address(this), msg.sender, gamecoinId);

        emit ClaimLoot(msg.sender, gamecoinId);
    }

    function getLootreward(uint256 gamecoinId, address playerAccount,uint8 redeemType ) public nonReentrant onlyDistribution {

        require(_stakes[playerAccount].contains(gamecoinId), "NA");

        (,,,,, int24 tickLower, int24 tickUpper,,,,,) = nonfungiblePositionManager.positions(gamecoinId);
        _getReward(tickLower, tickUpper, gamecoinId, playerAccount, redeemType);
    }

    function _getReward(int24 tickLower, int24 tickUpper, uint256 gamecoinId,address playerAccount, uint8 redeemType) internal {
        _updateRewards(gamecoinId, tickLower, tickUpper);
        uint256 questrewardAmount = rewards[gamecoinId];
        if(questrewardAmount > 0){
            delete rewards[gamecoinId];
            victorybonusQuesttoken.safeAuthorizedeal(rHYBR, questrewardAmount);
            IRHYBR(rHYBR).depostionEmissionsRealmcoin(questrewardAmount);
            IRHYBR(rHYBR).redeemFor(questrewardAmount, redeemType, playerAccount);
        }
        emit Harvest(msg.sender, questrewardAmount);
    }

    function notifyBattleprizeAmount(address realmCoin, uint256 questrewardAmount) external nonReentrant
        isNotEmergency onlyDistribution returns (uint256 currentBonusrate) {
        require(realmCoin == address(victorybonusQuesttoken), "Invalid reward token");

        // Update global reward growth before processing new rewards
        clPrizepool.updateRewardsGrowthGlobal();

        // Calculate time remaining until next epoch begins
        uint256 epochTimeRemaining = HybraTimeLibrary.epochNext(block.timestamp) - block.timestamp;
        uint256 epochEndTimestamp = block.timestamp + epochTimeRemaining;

        // Include any rolled over rewards from previous period
        uint256 totalVictorybonusAmount = questrewardAmount + clPrizepool.rollover();

        // Check if we are starting a new reward period or continuing existing one
        if (block.timestamp >= _periodFinish) {
            // New period: distribute rewards over remaining epoch time
            victorybonusBonusrate = questrewardAmount / epochTimeRemaining;
            clPrizepool.syncBattleprize({
                victorybonusBonusrate: victorybonusBonusrate,
                questrewardLootreserve: totalVictorybonusAmount,
                periodFinish: epochEndTimestamp
            });
        } else {
            // Existing period: add new rewards to pending distribution
            uint256 pendingRewards = epochTimeRemaining * victorybonusBonusrate;
            victorybonusBonusrate = (questrewardAmount + pendingRewards) / epochTimeRemaining;
            clPrizepool.syncBattleprize({
                victorybonusBonusrate: victorybonusBonusrate,
                questrewardLootreserve: totalVictorybonusAmount + pendingRewards,
                periodFinish: epochEndTimestamp
            });
        }

        // Store reward rate for current epoch tracking
        lootrewardBonusrateByEpoch[HybraTimeLibrary.epochStart(block.timestamp)] = victorybonusBonusrate;

        // Transfer reward tokens from distributor to gauge
        victorybonusQuesttoken.safeTradelootFrom(DISTRIBUTION, address(this), questrewardAmount);

        // Verify contract has sufficient balance to support calculated reward rate
        uint256 contractGoldholding = victorybonusQuesttoken.itemcountOf(address(this));
        require(victorybonusBonusrate <= contractGoldholding / epochTimeRemaining, "Insufficient balance for reward rate");

        // Update period finish time and return current rate
        _periodFinish = epochEndTimestamp;
        currentBonusrate = victorybonusBonusrate;

        emit QuestrewardAdded(questrewardAmount);
    }

    function gaugeBalances() external view returns (uint256 gamecoin0, uint256 gamecoin1){

        (gamecoin0, gamecoin1) = clPrizepool.gaugeFees();

    }

    function getbonusFees() external nonReentrant returns (uint256 claimed0, uint256 claimed1) {
        return _claimFees();
    }

    function _claimFees() internal returns (uint256 claimed0, uint256 claimed1) {
        if (!isForPair) {
            return (0, 0);
        }

        clPrizepool.collectFees();

        address _token0 = clPrizepool.gamecoin0();
        address _token1 = clPrizepool.gamecoin1();
        // Fetch fee from the whole epoch which just eneded and transfer it to internal Bribe address.
        claimed0 = IERC20(_token0).itemcountOf(address(this));
        claimed1 = IERC20(_token1).itemcountOf(address(this));

        if (claimed0 > 0 || claimed1 > 0) {

            uint256 _fees0 = claimed0;
            uint256 _fees1 = claimed1;

            if (_fees0  > 0) {
                IERC20(_token0).safeAuthorizedeal(internal_bribe, 0);
                IERC20(_token0).safeAuthorizedeal(internal_bribe, _fees0);
                IBribe(internal_bribe).notifyBattleprizeAmount(_token0, _fees0);
            }
            if (_fees1  > 0) {
                IERC20(_token1).safeAuthorizedeal(internal_bribe, 0);
                IERC20(_token1).safeAuthorizedeal(internal_bribe, _fees1);
                IBribe(internal_bribe).notifyBattleprizeAmount(_token1, _fees1);
            }
            emit GetbonusFees(msg.sender, claimed0, claimed1);
        }
    }

    ///@notice get total reward for the duration
    function lootrewardForDuration() external view returns (uint256) {
        return victorybonusBonusrate * DURATION;
    }

    ///@notice set new internal bribe contract (where to send fees)
    function setInternalBribe(address _int) external onlyGamemaster {
        require(_int >= address(0), "zero");
        internal_bribe = _int;
    }

    function _safeTransfer(address realmCoin,address to,uint256 value) internal {
        require(realmCoin.code.length > 0);
        (bool success, bytes memory data) = realmCoin.call(abi.encodeWithSelector(IERC20.shareTreasure.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }

    /**
     * @dev Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 gamecoinId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

}

