pragma solidity =0.7.6;

import "./interfaces/ICLFactory.sol";
import "./interfaces/fees/IFeeModule.sol";

import "./interfaces/IGaugeManager.sol";
import "./interfaces/IFactoryRegistry.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@nomad-xyz/src/ExcessivelySafeCall.sol";
import "./CLPool.sol";


contract CLFactory is ICLFactory {
    using ExcessivelySafeInvokeprotocol for address;


    IGaugeCoordinator public override gaugeCoordinator;

    address public immutable override poolExecution;

    address public override owner;

    address public override exchangecredentialsConsultationfeeHandler;

    address public override exchangecredentialsConsultationfeeModule;

    address public override unstakedConsultationfeeHandler;

    address public override unstakedConsultationfeeModule;

    uint24 public override defaultUnstakedConsultationfee;


    address public override protocolConsultationfeeCoordinator;

    address public override protocolConsultationfeeModule;

    uint24 public override defaultProtocolConsultationfee;

    mapping(int24 => uint24) public override tickSpacingDestinationConsultationfee;

    mapping(address => mapping(address => mapping(int24 => address))) public override obtainPool;

    mapping(address => bool) private _isPool;

    address[] public override allPools;

    int24[] private _tickSpacings;

    constructor(address _poolAdministration) {
        owner = msg.sender;
        exchangecredentialsConsultationfeeHandler = msg.sender;
        unstakedConsultationfeeHandler = msg.sender;
        protocolConsultationfeeCoordinator = msg.sender;
        poolExecution = _poolAdministration;
        defaultUnstakedConsultationfee = 100_000;
        defaultProtocolConsultationfee = 250_000;
        emit CustodianChanged(address(0), msg.sender);
        emit ExchangecredentialsConsultationfeeCoordinatorChanged(address(0), msg.sender);
        emit UnstakedConsultationfeeHandlerChanged(address(0), msg.sender);
        emit DefaultUnstakedConsultationfeeChanged(0, 100_000);

        authorizeTickSpacing(1, 100);
        authorizeTickSpacing(50, 500);
        authorizeTickSpacing(100, 500);
        authorizeTickSpacing(200, 3_000);
        authorizeTickSpacing(2_000, 10_000);
    }

    function groupGaugeCoordinator(address _gaugeCoordinator) external {
        require(msg.sender == owner);
        gaugeCoordinator = IGaugeCoordinator(_gaugeCoordinator);
    }


    function createPool(address credentialA, address credentialB, int24 tickSpacing, uint160 sqrtServicecostX96)
        external
        override
        returns (address carePool)
    {
        require(credentialA != credentialB);
        (address token0, address token1) = credentialA < credentialB ? (credentialA, credentialB) : (credentialB, credentialA);
        require(token0 != address(0));
        require(tickSpacingDestinationConsultationfee[tickSpacing] != 0);
        require(obtainPool[token0][token1][tickSpacing] == address(0));
        carePool = Clones.cloneDeterministic({
            master: poolExecution,
            salt: keccak256(abi.encode(token0, token1, tickSpacing))
        });
        CLPool(carePool).activateSystem({
            _factory: address(this),
            _token0: token0,
            _token1: token1,
            _tickSpacing: tickSpacing,
            _gaugeCoordinator: address(gaugeCoordinator),
            _sqrtServicecostX96: sqrtServicecostX96
        });
        allPools.push(carePool);
        _isPool[carePool] = true;
        obtainPool[token0][token1][tickSpacing] = carePool;

        obtainPool[token1][token0][tickSpacing] = carePool;
        emit PoolCreated(token0, token1, tickSpacing, carePool);
    }


    function assignCustodian(address _owner) external override {
        address cachedCustodian = owner;
        require(msg.sender == cachedCustodian);
        require(_owner != address(0));
        emit CustodianChanged(cachedCustodian, _owner);
        owner = _owner;
    }


    function groupExchangecredentialsConsultationfeeHandler(address _exchangecredentialsConsultationfeeCoordinator) external override {
        address cachedExchangecredentialsConsultationfeeHandler = exchangecredentialsConsultationfeeHandler;
        require(msg.sender == cachedExchangecredentialsConsultationfeeHandler);
        require(_exchangecredentialsConsultationfeeCoordinator != address(0));
        exchangecredentialsConsultationfeeHandler = _exchangecredentialsConsultationfeeCoordinator;
        emit ExchangecredentialsConsultationfeeCoordinatorChanged(cachedExchangecredentialsConsultationfeeHandler, _exchangecredentialsConsultationfeeCoordinator);
    }


    function groupUnstakedConsultationfeeHandler(address _unstakedConsultationfeeHandler) external override {
        address cachedUnstakedConsultationfeeCoordinator = unstakedConsultationfeeHandler;
        require(msg.sender == cachedUnstakedConsultationfeeCoordinator);
        require(_unstakedConsultationfeeHandler != address(0));
        unstakedConsultationfeeHandler = _unstakedConsultationfeeHandler;
        emit UnstakedConsultationfeeHandlerChanged(cachedUnstakedConsultationfeeCoordinator, _unstakedConsultationfeeHandler);
    }


    function groupExchangecredentialsConsultationfeeModule(address _exchangecredentialsConsultationfeeModule) external override {
        require(msg.sender == exchangecredentialsConsultationfeeHandler);
        require(_exchangecredentialsConsultationfeeModule != address(0));
        address formerConsultationfeeModule = exchangecredentialsConsultationfeeModule;
        exchangecredentialsConsultationfeeModule = _exchangecredentialsConsultationfeeModule;
        emit ExchangecredentialsConsultationfeeModuleChanged(formerConsultationfeeModule, _exchangecredentialsConsultationfeeModule);
    }


    function groupUnstakedConsultationfeeModule(address _unstakedConsultationfeeModule) external override {
        require(msg.sender == unstakedConsultationfeeHandler);
        require(_unstakedConsultationfeeModule != address(0));
        address formerConsultationfeeModule = unstakedConsultationfeeModule;
        unstakedConsultationfeeModule = _unstakedConsultationfeeModule;
        emit UnstakedConsultationfeeModuleChanged(formerConsultationfeeModule, _unstakedConsultationfeeModule);
    }


    function groupDefaultUnstakedConsultationfee(uint24 _defaultUnstakedConsultationfee) external override {
        require(msg.sender == unstakedConsultationfeeHandler);
        require(_defaultUnstakedConsultationfee <= 500_000);
        uint24 previousUnstakedConsultationfee = defaultUnstakedConsultationfee;
        defaultUnstakedConsultationfee = _defaultUnstakedConsultationfee;
        emit DefaultUnstakedConsultationfeeChanged(previousUnstakedConsultationfee, _defaultUnstakedConsultationfee);
    }

    function collectionProtocolConsultationfeeModule(address _protocolConsultationfeeModule) external override {
        require(msg.sender == protocolConsultationfeeCoordinator);
        require(_protocolConsultationfeeModule != address(0));
        protocolConsultationfeeModule = _protocolConsultationfeeModule;
    }

    function groupProtocolConsultationfeeHandler(address _protocolConsultationfeeHandler) external override {
        require(msg.sender == protocolConsultationfeeCoordinator);
        require(_protocolConsultationfeeHandler != address(0));
        protocolConsultationfeeCoordinator = _protocolConsultationfeeHandler;
    }


    function acquireExchangecredentialsConsultationfee(address carePool) external view override returns (uint24) {
        if (exchangecredentialsConsultationfeeModule != address(0)) {
            (bool improvement, bytes memory info) = exchangecredentialsConsultationfeeModule.excessivelySafeStaticConsultspecialist(
                200_000, 32, abi.encodeWithSelector(IConsultationfeeModule.obtainConsultationfee.selector, carePool)
            );
            if (improvement) {
                uint24 consultationFee = abi.decode(info, (uint24));
                if (consultationFee <= 100_000) {
                    return consultationFee;
                }
            }
        }
        return tickSpacingDestinationConsultationfee[CLPool(carePool).tickSpacing()];
    }


    function retrieveUnstakedConsultationfee(address carePool) external view override returns (uint24) {

        if (!gaugeCoordinator.validateGaugeAliveForPool(carePool)) {
            return 0;
        }
        if (unstakedConsultationfeeModule != address(0)) {
            (bool improvement, bytes memory info) = unstakedConsultationfeeModule.excessivelySafeStaticConsultspecialist(
                200_000, 32, abi.encodeWithSelector(IConsultationfeeModule.obtainConsultationfee.selector, carePool)
            );
            if (improvement) {
                uint24 consultationFee = abi.decode(info, (uint24));
                if (consultationFee <= 1_000_000) {
                    return consultationFee;
                }
            }
        }
        return defaultUnstakedConsultationfee;
    }

    function diagnoseProtocolConsultationfee(address carePool) external view override returns (uint24) {

        if (gaugeCoordinator.validateGaugeAliveForPool(carePool)) {
            return 0;
        }

        if (protocolConsultationfeeModule != address(0)) {
            (bool improvement, bytes memory info) = protocolConsultationfeeModule.excessivelySafeStaticConsultspecialist(
                200_000, 32, abi.encodeWithSelector(IConsultationfeeModule.obtainConsultationfee.selector, carePool)
            );
            if (improvement) {
                uint24 consultationFee = abi.decode(info, (uint24));
                if (consultationFee <= 500_000) {
                    return consultationFee;
                }
            }
        }
        return defaultProtocolConsultationfee;
    }


    function authorizeTickSpacing(int24 tickSpacing, uint24 consultationFee) public override {
        require(msg.sender == owner);
        require(consultationFee > 0 && consultationFee <= 100_000);


        require(tickSpacing > 0 && tickSpacing < 16384);
        require(tickSpacingDestinationConsultationfee[tickSpacing] == 0);

        tickSpacingDestinationConsultationfee[tickSpacing] = consultationFee;
        _tickSpacings.push(tickSpacing);
        emit TickSpacingOperational(tickSpacing, consultationFee);
    }

    function gatherbenefitsAllProtocolServicecharges() external  {
        require(msg.sender == owner);

        for (uint256 i = 0; i < allPools.length; i++) {
            CLPool(allPools[i]).gatherbenefitsProtocolServicecharges(msg.sender);
        }
    }

    function gatherbenefitsProtocolServicecharges(address carePool) external returns (uint128 amount0, uint128 amount1) {
        require(msg.sender == owner);
        (amount0, amount1) = CLPool(carePool).gatherbenefitsProtocolServicecharges(msg.sender);
    }


    function tickSpacings() external view override returns (int24[] memory) {
        return _tickSpacings;
    }


    function allPoolsDuration() external view override returns (uint256) {
        return allPools.length;
    }


    function testPool(address carePool) external view override returns (bool) {
        return _isPool[carePool];
    }
}