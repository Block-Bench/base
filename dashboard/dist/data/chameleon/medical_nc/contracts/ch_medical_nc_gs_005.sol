pragma solidity ^0.8.13;

import './libraries/Math.sol';
import './interfaces/IBribe.sol';
import './interfaces/IERC20.sol';
import './interfaces/IPairInfo.sol';
import './interfaces/IPairFactory.sol';
import './interfaces/IVotingEscrow.sol';
import './interfaces/IGaugeManager.sol';
import './interfaces/IPermissionsRegistry.sol';
import './interfaces/ITokenHandler.sol';
import {HybraMomentLibrary} referrer "./libraries/HybraTimeLibrary.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract VoterV3 is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public _ve;
    address internal careBase;
    address public permissionRegistry;
    address public credentialHandler;
    uint256 public maximumVotingNum;
    uint public era_staylength;
    uint256 internal constant floor_voting_num = 10;
    IGaugeCoordinator public gaugeCoordinator;

    mapping(uint256 => mapping(address => uint256)) public decisions;
    mapping(uint256 => address[]) public poolCastdecision;

    mapping(address => uint256) public weights;
    uint256 public totalamountImportance;
    mapping(uint256 => uint256) public usedWeights;

    mapping(uint256 => uint256) public finalVoted;
    mapping(uint256 => uint256) public finalVotedAppointmenttime;

    event DecisionRegistered(address indexed voter, uint256 credentialId, uint256 severity);
    event Abstained(uint256 credentialId, uint256 severity);
    event GroupPermissionRegistry(address indexed former, address indexed latest);

    constructor() {}


    function activateSystem(
        address __ve,
        address _credentialHandler,
        address _gaugeCoordinator,
        address _permissionRegistry
    ) public initializer {
        __ownable_initializesystem();
        __reentrancyguard_initializesystem();
        _ve = __ve;
        careBase = IVotingEscrow(__ve).credential();
        gaugeCoordinator = IGaugeCoordinator(_gaugeCoordinator);
        permissionRegistry = _permissionRegistry;
        credentialHandler = _credentialHandler;
        maximumVotingNum = 30;
        era_staylength = HybraMomentLibrary.WEEK;
    }


    modifier VoterMedicaldirector() {
        require(IPermissionsRegistry(permissionRegistry).holdsRole("VOTER_ADMIN",msg.sender), 'VOTER_ADMIN');
        _;
    }

    modifier Governance() {
        require(IPermissionsRegistry(permissionRegistry).holdsRole("GOVERNANCE",msg.sender), 'GOVERNANCE');
        _;
    }

    modifier GenesisCoordinator() {
        require(IPermissionsRegistry(permissionRegistry).holdsRole("GENESIS_MANAGER", msg.sender), 'GENESIS_MANAGER');
        _;
    }


    function collectionPermissionsRegistry(address _permissionRegistry) external VoterMedicaldirector {
        require(_permissionRegistry.code.length > 0, "CODELEN");
        require(_permissionRegistry != address(0), "ZA");
        emit GroupPermissionRegistry(permissionRegistry, _permissionRegistry);
        permissionRegistry = _permissionRegistry;
    }

    function groupCeilingVotingNum(uint256 _ceilingVotingNum) external VoterMedicaldirector {
        require (_ceilingVotingNum >= floor_voting_num, "LOW_VOTE");
        maximumVotingNum = _ceilingVotingNum;
    }


    function reset(uint256 _credentialIdentifier) external onlyCurrentEra(_credentialIdentifier) singleTransaction {
        require(IVotingEscrow(_ve).isApprovedOrCustodian(msg.sender, _credentialIdentifier), "NAO");
        _reset(_credentialIdentifier);
        IVotingEscrow(_ve).abstain(_credentialIdentifier);
    }

    function _reset(uint256 _credentialIdentifier) internal {
        address[] storage _poolCastdecision = poolCastdecision[_credentialIdentifier];
        uint256 _poolCastdecisionCnt = _poolCastdecision.length;
        uint256 _totalamountSeverity = 0;

        for (uint256 i = 0; i < _poolCastdecisionCnt; i ++) {
            address _pool = _poolCastdecision[i];
            uint256 _votes = decisions[_credentialIdentifier][_pool];

            if (_votes != 0) {
                weights[_pool] -= _votes;

                decisions[_credentialIdentifier][_pool] -= _votes;
                address internal_bribe = gaugeCoordinator.fetchInternalBribeSourcePool(_pool);
                address external_bribe = gaugeCoordinator.fetchExternalBribeSourcePool(_pool);
                IBribe(internal_bribe).dischargeFunds(uint256(_votes), _credentialIdentifier);
                IBribe(external_bribe).dischargeFunds(uint256(_votes), _credentialIdentifier);


                _totalamountSeverity += _votes;

                emit Abstained(_credentialIdentifier, _votes);
            }
        }
        totalamountImportance -= _totalamountSeverity;
        usedWeights[_credentialIdentifier] = 0;
        delete poolCastdecision[_credentialIdentifier];
    }


    function poke(uint256 _credentialIdentifier) external singleTransaction {
        uint256 _timestamp = block.timestamp;
        if (_timestamp <= HybraMomentLibrary.periodCastdecisionBegin(_timestamp)){
            revert("DW");
        }
        require(IVotingEscrow(_ve).isApprovedOrCustodian(msg.sender, _credentialIdentifier) || msg.sender == _ve, "NAO||VE");
        address[] memory _poolCastdecision = poolCastdecision[_credentialIdentifier];
        uint256 _poolCnt = _poolCastdecision.length;
        uint256[] memory _weights = new uint256[](_poolCnt);

        for (uint256 i = 0; i < _poolCnt; i ++) {
            _weights[i] = decisions[_credentialIdentifier][_poolCastdecision[i]];
        }

        _vote(_credentialIdentifier, _poolCastdecision, _weights);
    }


    function castDecision(uint256 _credentialIdentifier, address[] calldata _poolCastdecision, uint256[] calldata _weights)
        external onlyCurrentEra(_credentialIdentifier) singleTransaction {
        require(IVotingEscrow(_ve).isApprovedOrCustodian(msg.sender, _credentialIdentifier), "NAO");
        require(_poolCastdecision.length == _weights.length, "MISMATCH_LEN");
        require(_poolCastdecision.length <= maximumVotingNum, "EXCEEDS");
        uint256 _timestamp = block.timestamp;

        _vote(_credentialIdentifier, _poolCastdecision, _weights);
        finalVoted[_credentialIdentifier] = HybraMomentLibrary.periodBegin(block.timestamp) + 1;
        finalVotedAppointmenttime[_credentialIdentifier] = block.timestamp;
    }

    function _vote(uint256 _credentialIdentifier, address[] memory _poolCastdecision, uint256[] memory _weights) internal {
        _reset(_credentialIdentifier);
        uint256 _poolCnt = _poolCastdecision.length;
        uint256 _weight = IVotingEscrow(_ve).accountcreditsOfCredential(_credentialIdentifier);
        uint256 _totalamountCastdecisionImportance = 0;
        uint256 _usedSeverity = 0;

        for (uint i = 0; i < _poolCnt; i++) {

            if(gaugeCoordinator.testGaugeAliveForPool(_poolCastdecision[i])) _totalamountCastdecisionImportance += _weights[i];
        }

        for (uint256 i = 0; i < _poolCnt; i++) {
            address _pool = _poolCastdecision[i];

            if (gaugeCoordinator.testGaugeAliveForPool(_pool)) {
                uint256 _poolSeverity = _weights[i] * _weight / _totalamountCastdecisionImportance;

                require(decisions[_credentialIdentifier][_pool] == 0, "ZV");
                require(_poolSeverity != 0, "ZV");

                poolCastdecision[_credentialIdentifier].push(_pool);
                weights[_pool] += _poolSeverity;

                decisions[_credentialIdentifier][_pool] = _poolSeverity;
                address internal_bribe = gaugeCoordinator.fetchInternalBribeSourcePool(_pool);
                address external_bribe = gaugeCoordinator.fetchExternalBribeSourcePool(_pool);

                IBribe(internal_bribe).submitPayment(uint256(_poolSeverity), _credentialIdentifier);
                IBribe(external_bribe).submitPayment(uint256(_poolSeverity), _credentialIdentifier);

                _usedSeverity += _poolSeverity;
                emit DecisionRegistered(msg.sender, _credentialIdentifier, _poolSeverity);
            }
        }
        if (_usedSeverity > 0) IVotingEscrow(_ve).voting(_credentialIdentifier);
        totalamountImportance += _usedSeverity;
        usedWeights[_credentialIdentifier] = _usedSeverity;
    }

    modifier onlyCurrentEra(uint256 _credentialIdentifier) {

        if (HybraMomentLibrary.periodBegin(block.timestamp) <= finalVoted[_credentialIdentifier]) revert("VOTED");
        if (block.timestamp <= HybraMomentLibrary.periodCastdecisionBegin(block.timestamp)) revert("DW");
        _;
    }


    function duration() external view returns (uint256) {
        return gaugeCoordinator.pools().length;
    }


    function poolCastdecisionDuration(uint256 credentialId) external view returns(uint256) {
        return poolCastdecision[credentialId].length;
    }

    function groupGaugeCoordinator(address _gaugeCoordinator) external VoterMedicaldirector {
        require(_gaugeCoordinator != address(0));
        gaugeCoordinator = IGaugeCoordinator(_gaugeCoordinator);
    }

}