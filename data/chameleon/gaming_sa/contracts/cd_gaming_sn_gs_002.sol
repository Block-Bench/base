// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./interfaces/ICLFactory.sol";
import "./interfaces/fees/IFeeModule.sol";

import "./interfaces/IGaugeManager.sol";
import "./interfaces/IFactoryRegistry.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@nomad-xyz/src/ExcessivelySafeCall.sol";
import "./CLPool.sol";

/// @title Canonical CL factory
/// @notice Deploys CL pools and manages ownership and control over pool protocol fees
contract CLFactory is ICLFactory {
    using ExcessivelySafeCall for address;

    /// @inheritdoc ICLFactory
    IGaugeManager public override gaugeManager;
    /// @inheritdoc ICLFactory
    address public immutable override bountypoolImplementation;
    /// @inheritdoc ICLFactory
    address public override guildLeader;
    /// @inheritdoc ICLFactory
    address public override convertgemsServicefeeManager;
    /// @inheritdoc ICLFactory
    address public override convertgemsTaxModule;
    /// @inheritdoc ICLFactory
    address public override unstakedTributeManager;
    /// @inheritdoc ICLFactory
    address public override unstakedRakeModule;
    /// @inheritdoc ICLFactory
    uint24 public override defaultUnstakedCut;
    /// @inheritdoc ICLFactory

    address public override protocolRakeManager;
    /// @inheritdoc ICLFactory
    address public override protocolTaxModule;
    /// @inheritdoc ICLFactory
    uint24 public override defaultProtocolCut;

    mapping(int24 => uint24) public override tickSpacingToRake;
    /// @inheritdoc ICLFactory
    mapping(address => mapping(address => mapping(int24 => address))) public override getLootpool;
    /// @dev Used in VotingEscrow to determine if a contract is a valid pool
    mapping(address => bool) private _isPool;
    /// @inheritdoc ICLFactory
    address[] public override allPools;

    int24[] private _tickSpacings;

    constructor(address _poolImplementation) {
        guildLeader = msg.sender;
        convertgemsServicefeeManager = msg.sender;
        unstakedTributeManager = msg.sender;
        protocolRakeManager = msg.sender;
        bountypoolImplementation = _poolImplementation;
        defaultUnstakedCut = 100_000;
        defaultProtocolCut = 250_000;
        emit DungeonmasterChanged(address(0), msg.sender);
        emit ExchangegoldRakeManagerChanged(address(0), msg.sender);
        emit UnstakedServicefeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedServicefeeChanged(0, 100_000);

        enableTickSpacing(1, 100);
        enableTickSpacing(50, 500);
        enableTickSpacing(100, 500);
        enableTickSpacing(200, 3_000);
        enableTickSpacing(2_000, 10_000);
    }

    function setGaugeManager(address _gaugeManager) external {
        require(msg.sender == guildLeader);
        gaugeManager = IGaugeManager(_gaugeManager);
    }

    /// @inheritdoc ICLFactory
    function createLootpool(address goldtokenA, address gamecoinB, int24 tickSpacing, uint160 sqrtPriceX96)
        external
        override
        returns (address lootPool)
    {
        require(goldtokenA != gamecoinB);
        (address realmcoin0, address questtoken1) = goldtokenA < gamecoinB ? (goldtokenA, gamecoinB) : (gamecoinB, goldtokenA);
        require(realmcoin0 != address(0));
        require(tickSpacingToRake[tickSpacing] != 0);
        require(getLootpool[realmcoin0][questtoken1][tickSpacing] == address(0));
        lootPool = Clones.cloneDeterministic({
            master: bountypoolImplementation,
            salt: keccak256(abi.encode(realmcoin0, questtoken1, tickSpacing))
        });
        ClRewardpool(lootPool).initialize({
            _factory: address(this),
            _token0: realmcoin0,
            _token1: questtoken1,
            _tickSpacing: tickSpacing,
            _gaugeManager: address(gaugeManager),
            _sqrtPriceX96: sqrtPriceX96
        });
        allPools.push(lootPool);
        _isPool[lootPool] = true;
        getLootpool[realmcoin0][questtoken1][tickSpacing] = lootPool;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        getLootpool[questtoken1][realmcoin0][tickSpacing] = lootPool;
        emit PrizepoolCreated(realmcoin0, questtoken1, tickSpacing, lootPool);
    }

    /// @inheritdoc ICLFactory
    function setDungeonmaster(address _dungeonmaster) external override {
        address cachedGuildleader = guildLeader;
        require(msg.sender == cachedGuildleader);
        require(_dungeonmaster != address(0));
        emit DungeonmasterChanged(cachedGuildleader, _dungeonmaster);
        guildLeader = _dungeonmaster;
    }

    /// @inheritdoc ICLFactory
    function setTradeitemsTaxManager(address _swapFeeManager) external override {
        address cachedSwaplootTaxManager = convertgemsServicefeeManager;
        require(msg.sender == cachedSwaplootTaxManager);
        require(_swapFeeManager != address(0));
        convertgemsServicefeeManager = _swapFeeManager;
        emit ExchangegoldRakeManagerChanged(cachedSwaplootTaxManager, _swapFeeManager);
    }

    /// @inheritdoc ICLFactory
    function setUnstakedServicefeeManager(address _unstakedFeeManager) external override {
        address cachedUnstakedServicefeeManager = unstakedTributeManager;
        require(msg.sender == cachedUnstakedServicefeeManager);
        require(_unstakedFeeManager != address(0));
        unstakedTributeManager = _unstakedFeeManager;
        emit UnstakedServicefeeManagerChanged(cachedUnstakedServicefeeManager, _unstakedFeeManager);
    }

    /// @inheritdoc ICLFactory
    function setConvertgemsServicefeeModule(address _swapFeeModule) external override {
        require(msg.sender == convertgemsServicefeeManager);
        require(_swapFeeModule != address(0));
        address oldTributeModule = convertgemsTaxModule;
        convertgemsTaxModule = _swapFeeModule;
        emit SwaplootRakeModuleChanged(oldTributeModule, _swapFeeModule);
    }

    /// @inheritdoc ICLFactory
    function setUnstakedTributeModule(address _unstakedFeeModule) external override {
        require(msg.sender == unstakedTributeManager);
        require(_unstakedFeeModule != address(0));
        address oldTributeModule = unstakedRakeModule;
        unstakedRakeModule = _unstakedFeeModule;
        emit UnstakedTaxModuleChanged(oldTributeModule, _unstakedFeeModule);
    }

    /// @inheritdoc ICLFactory
    function setDefaultUnstakedTax(uint24 _defaultUnstakedFee) external override {
        require(msg.sender == unstakedTributeManager);
        require(_defaultUnstakedFee <= 500_000);
        uint24 oldUnstakedServicefee = defaultUnstakedCut;
        defaultUnstakedCut = _defaultUnstakedFee;
        emit DefaultUnstakedServicefeeChanged(oldUnstakedServicefee, _defaultUnstakedFee);
    }

    function setProtocolRakeModule(address _protocolFeeModule) external override {
        require(msg.sender == protocolRakeManager);
        require(_protocolFeeModule != address(0));
        protocolTaxModule = _protocolFeeModule;
    }

    function setProtocolServicefeeManager(address _protocolFeeManager) external override {
        require(msg.sender == protocolRakeManager);
        require(_protocolFeeManager != address(0));
        protocolRakeManager = _protocolFeeManager;
    }

    /// @inheritdoc ICLFactory
    function getConvertgemsRake(address lootPool) external view override returns (uint24) {
        if (convertgemsTaxModule != address(0)) {
            (bool success, bytes memory data) = convertgemsTaxModule.excessivelySafeStaticCall(
                200_000, 32, abi.encodeWithSelector(ITributeModule.getRake.selector, lootPool)
            );
            if (success) {
                uint24 serviceFee = abi.decode(data, (uint24));
                if (serviceFee <= 100_000) {
                    return serviceFee;
                }
            }
        }
        return tickSpacingToRake[ClRewardpool(lootPool).tickSpacing()];
    }

    /// @inheritdoc ICLFactory
    function getUnstakedTax(address lootPool) external view override returns (uint24) {

        if (!gaugeManager.isGaugeAliveForPrizepool(lootPool)) {
            return 0;
        }
        if (unstakedRakeModule != address(0)) {
            (bool success, bytes memory data) = unstakedRakeModule.excessivelySafeStaticCall(
                200_000, 32, abi.encodeWithSelector(ITributeModule.getRake.selector, lootPool)
            );
            if (success) {
                uint24 serviceFee = abi.decode(data, (uint24));
                if (serviceFee <= 1_000_000) {
                    return serviceFee;
                }
            }
        }
        return defaultUnstakedCut;
    }

    function getProtocolTax(address lootPool) external view override returns (uint24) {
        // if the gauge is alive, return 0, protocol fee is only for inactive gauges
        if (gaugeManager.isGaugeAliveForPrizepool(lootPool)) {
            return 0;
        }

        if (protocolTaxModule != address(0)) {
            (bool success, bytes memory data) = protocolTaxModule.excessivelySafeStaticCall(
                200_000, 32, abi.encodeWithSelector(ITributeModule.getRake.selector, lootPool)
            );
            if (success) {
                uint24 serviceFee = abi.decode(data, (uint24));
                if (serviceFee <= 500_000) {
                    return serviceFee;
                }
            }
        }
        return defaultProtocolCut;
    }

    /// @inheritdoc ICLFactory
    function enableTickSpacing(int24 tickSpacing, uint24 serviceFee) public override {
        require(msg.sender == guildLeader);
        require(serviceFee > 0 && serviceFee <= 100_000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that

        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(tickSpacing > 0 && tickSpacing < 16384);
        require(tickSpacingToRake[tickSpacing] == 0);

        tickSpacingToRake[tickSpacing] = serviceFee;
        _tickSpacings.push(tickSpacing);
        emit TickSpacingEnabled(tickSpacing, serviceFee);
    }

    function collectAllProtocolFees() external  {
        require(msg.sender == guildLeader);

        for (uint256 i = 0; i < allPools.length; i++) {
            ClRewardpool(allPools[i]).collectProtocolFees(msg.sender);
        }
    }

    function collectProtocolFees(address lootPool) external returns (uint128 amount0, uint128 amount1) {
        require(msg.sender == guildLeader);
        (amount0, amount1) = ClRewardpool(lootPool).collectProtocolFees(msg.sender);
    }

    /// @inheritdoc ICLFactory
    function tickSpacings() external view override returns (int24[] memory) {
        return _tickSpacings;
    }

    /// @inheritdoc ICLFactory
    function allPoolsLength() external view override returns (uint256) {
        return allPools.length;
    }

    /// @inheritdoc ICLFactory
    function isPrizepool(address lootPool) external view override returns (bool) {
        return _isPool[lootPool];
    }
}