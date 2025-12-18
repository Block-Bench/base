// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.8.31;

import "./interfaces/ICLFactory.sol";
import "./interfaces/fees/IFeeModule.sol";
import "./interfaces/IGaugeManager.sol";
import "./interfaces/IFactoryRegistry.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@nomad-xyz/src/ExcessivelySafeCall.sol";
import "./CLPool.sol";

contract CLFactory is ICLFactory {
    using ExcessivelySafeCall for address;

    IGaugeManager public override gaugeManager;
    address public immutable override poolImplementation;
    address public override owner;
    address public override swapFeeManager;
    address public override swapFeeModule;
    address public override unstakedFeeManager;
    address public override unstakedFeeModule;
    uint24 public override defaultUnstakedFee;

    address public override protocolFeeManager;
    address public override protocolFeeModule;
    uint24 public override defaultProtocolFee;

    // Analytics tracking
    uint256 public protocolVersion;
    uint256 public totalPoolCreations;
    mapping(address => uint256) public poolFeeQueries;

    mapping(int24 => uint24) public override tickSpacingToFee;
    mapping(address => mapping(address => mapping(int24 => address))) public override getPool;
    mapping(address => bool) private _isPool;
    address[] public override allPools;

    int24[] private _tickSpacings;

    event PoolMetricsUpdated(uint256 totalPools, uint256 version);
    event FeeQueryRecorded(address indexed pool, uint256 queryCount);

    constructor(address _poolImplementation) {
        owner = msg.sender;
        swapFeeManager = msg.sender;
        unstakedFeeManager = msg.sender;
        protocolFeeManager = msg.sender;
        poolImplementation = _poolImplementation;
        defaultUnstakedFee = 100_000;
        defaultProtocolFee = 250_000;
        emit OwnerChanged(address(0), msg.sender);
        emit SwapFeeManagerChanged(address(0), msg.sender);
        emit UnstakedFeeManagerChanged(address(0), msg.sender);
        emit DefaultUnstakedFeeChanged(0, 100_000);

        enableTickSpacing(1, 100);
        enableTickSpacing(50, 500);
        enableTickSpacing(100, 500);
        enableTickSpacing(200, 3_000);
        enableTickSpacing(2_000, 10_000);
    }

    function setGaugeManager(address _gaugeManager) external {
        require(msg.sender == owner);
        gaugeManager = IGaugeManager(_gaugeManager);
    }

    // VULNERABILITY PRESERVED: Silent fee clamp above 100_000
    function getSwapFee(address pool) external view override returns (uint24) {
        poolFeeQueries[pool] += 1; // Track fee queries
        
        if (swapFeeModule != address(0)) {
            (bool success, bytes memory data) = swapFeeModule.excessivelySafeStaticCall(
                200_000, 32, abi.encodeWithSelector(IFeeModule.getFee.selector, pool)
            );
            if (success) {
                uint24 fee = abi.decode(data, (uint24));
                // Silently discards fees > 100_000 (10%)
                if (fee <= 100_000) {
                    return fee;
                }
            }
        }
        return tickSpacingToFee[CLPool(pool).tickSpacing()];
    }

    function getUnstakedFee(address pool) external view override returns (uint24) {
        poolFeeQueries[pool] += 1;
        
        if (!gaugeManager.isGaugeAliveForPool(pool)) {
            return 0;
        }
        if (unstakedFeeModule != address(0)) {
            (bool success, bytes memory data) = unstakedFeeModule.excessivelySafeStaticCall(
                200_000, 32, abi.encodeWithSelector(IFeeModule.getFee.selector, pool)
            );
            if (success) {
                uint24 fee = abi.decode(data, (uint24));
                if (fee <= 1_000_000) {
                    return fee;
                }
            }
        }
        return defaultUnstakedFee;
    }

    function getProtocolFee(address pool) external view override returns (uint24) {
        poolFeeQueries[pool] += 1;
        
        if (gaugeManager.isGaugeAliveForPool(pool)) {
            return 0;
        }

        if (protocolFeeModule != address(0)) {
            (bool success, bytes memory data) = protocolFeeModule.excessivelySafeStaticCall(
                200_000, 32, abi.encodeWithSelector(IFeeModule.getFee.selector, pool)
            );
            if (success) {
                uint24 fee = abi.decode(data, (uint24));
                if (fee <= 500_000) {
                    return fee;
                }
            }
        }
        return defaultProtocolFee;
    }

    function createPool(address tokenA, address tokenB, int24 tickSpacing, uint160 sqrtPriceX96)
        external
        override
        returns (address pool)
    {
        totalPoolCreations += 1;
        
        require(tokenA != tokenB);
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0));
        require(tickSpacingToFee[tickSpacing] != 0);
        require(getPool[token0][token1][tickSpacing] == address(0));
        pool = Clones.cloneDeterministic({
            master: poolImplementation,
            salt: keccak256(abi.encode(token0, token1, tickSpacing))
        });
        CLPool(pool).initialize({
            _factory: address(this),
            _token0: token0,
            _token1: token1,
            _tickSpacing: tickSpacing,
            _gaugeManager: address(gaugeManager),
            _sqrtPriceX96: sqrtPriceX96
        });
        allPools.push(pool);
        _isPool[pool] = true;
        getPool[token0][token1][tickSpacing] = pool;
        getPool[token1][token0][tickSpacing] = pool;
        emit PoolCreated(token0, token1, tickSpacing, pool);
        emit PoolMetricsUpdated(allPools.length, protocolVersion);
    }

    function setOwner(address _owner) external override {
        address cachedOwner = owner;
        require(msg.sender == cachedOwner);
        require(_owner != address(0));
        emit OwnerChanged(cachedOwner, _owner);
        owner = _owner;
    }

    function setSwapFeeManager(address _swapFeeManager) external override {
        address cachedSwapFeeManager = swapFeeManager;
        require(msg.sender == cachedSwapFeeManager);
        require(_swapFeeManager != address(0));
        swapFeeManager = _swapFeeManager;
        emit SwapFeeManagerChanged(cachedSwapFeeManager, _swapFeeManager);
    }

    function setUnstakedFeeManager(address _unstakedFeeManager) external override {
        address cachedUnstakedFeeManager = unstakedFeeManager;
        require(msg.sender == cachedUnstakedFeeManager);
        require(_unstakedFeeManager != address(0));
        unstakedFeeManager = _unstakedFeeManager;
        emit UnstakedFeeManagerChanged(cachedUnstakedFeeManager, _unstakedFeeManager);
    }

    function setSwapFeeModule(address _swapFeeModule) external override {
        require(msg.sender == swapFeeManager);
        require(_swapFeeModule != address(0));
        address oldFeeModule = swapFeeModule;
        swapFeeModule = _swapFeeModule;
        emit SwapFeeModuleChanged(oldFeeModule, _swapFeeModule);
    }

    function setUnstakedFeeModule(address _unstakedFeeModule) external override {
        require(msg.sender == unstakedFeeManager);
        require(_unstakedFeeModule != address(0));
        address oldFeeModule = unstakedFeeModule;
        unstakedFeeModule = _unstakedFeeModule;
        emit UnstakedFeeModuleChanged(oldFeeModule, _unstakedFeeModule);
    }

    function setDefaultUnstakedFee(uint24 _defaultUnstakedFee) external override {
        require(msg.sender == unstakedFeeManager);
        require(_defaultUnstakedFee <= 500_000);
        uint24 oldUnstakedFee = defaultUnstakedFee;
        defaultUnstakedFee = _defaultUnstakedFee;
        emit DefaultUnstakedFeeChanged(oldUnstakedFee, _defaultUnstakedFee);
    }

    function setProtocolFeeModule(address _protocolFeeModule) external override {
        require(msg.sender == protocolFeeManager);
        require(_protocolFeeModule != address(0));
        protocolFeeModule = _protocolFeeModule;
    }

    function setProtocolFeeManager(address _protocolFeeManager) external override {
        require(msg.sender == protocolFeeManager);
        require(_protocolFeeManager != address(0));
        protocolFeeManager = _protocolFeeManager;
    }

    function enableTickSpacing(int24 tickSpacing, uint24 fee) public override {
        require(msg.sender == owner);
        require(fee > 0 && fee <= 100_000);
        require(tickSpacing > 0 && tickSpacing < 16384);
        require(tickSpacingToFee[tickSpacing] == 0);

        tickSpacingToFee[tickSpacing] = fee;
        _tickSpacings.push(tickSpacing);
        emit TickSpacingEnabled(tickSpacing, fee);
    }

    function collectAllProtocolFees() external {
        require(msg.sender == owner);

        for (uint256 i = 0; i < allPools.length; i++) {
            CLPool(allPools[i]).collectProtocolFees(msg.sender);
        }
    }

    function collectProtocolFees(address pool) external returns (uint128 amount0, uint128 amount1) {
        require(msg.sender == owner);
        (amount0, amount1) = CLPool(pool).collectProtocolFees(msg.sender);
    }

    function tickSpacings() external view override returns (int24[] memory) {
        return _tickSpacings;
    }

    function allPoolsLength() external view override returns (uint256) {
        return allPools.length;
    }

    function isPool(address pool) external view override returns (bool) {
        return _isPool[pool];
    }

    function updateProtocolVersion(uint256 newVersion) external {
        require(msg.sender == owner);
        protocolVersion = newVersion;
    }

    function getFactoryMetrics() external view returns (
        uint256 version,
        uint256 totalPools,
        uint256 totalFeeQueries
    ) {
        version = protocolVersion;
        totalPools = allPools.length;
        totalFeeQueries = 0;
        // Scan recent pools for fee query activity
        for (uint256 i = 0; i < allPools.length && i < 100; i++) {
            totalFeeQueries += poolFeeQueries[allPools[i]];
        }
    }
}
