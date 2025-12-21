pragma solidity ^0.8.20;

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable} from
    "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20Upgradeable} from "openzeppelin-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import {ProtocolEvents} from "./interfaces/ProtocolEvents.sol";
import {IDepositContract} from "./interfaces/IDepositContract.sol";
import {IMETH} from "./interfaces/IMETH.sol";
import {IOracleReadRecord, OracleRecord} from "./interfaces/IOracle.sol";
import {IPauserRead} from "./interfaces/IPauser.sol";
import {IStaking, IStakingReturnsWrite, IStakingInitiationRead} from "./interfaces/IStaking.sol";
import {UnstakeRequest, IUnstakeRequestsManager} from "./interfaces/IUnstakeRequestsManager.sol";

import {ILiquidityBuffer} from "./liquidityBuffer/interfaces/ILiquidityBuffer.sol";


interface StakingEvents {

    event Staked(address indexed _0x7ca589, uint256 _0xb269de, uint256 _0xf800e2);


    event UnstakeRequested(uint256 indexed _0xabb4dd, address indexed _0x7ca589, uint256 _0xb269de, uint256 _0x804d1e);


    event UnstakeRequestClaimed(uint256 indexed _0xabb4dd, address indexed _0x7ca589);


    event ValidatorInitiated(bytes32 indexed _0xabb4dd, uint256 indexed _0x435b41, bytes _0xf2101e, uint256 _0xe40df6);


    event AllocatedETHToUnstakeRequestsManager(uint256 _0xea5edb);


    event AllocatedETHToDeposits(uint256 _0xea5edb);


    event ReturnsReceived(uint256 _0xea5edb);


    event ReturnsReceivedFromLiquidityBuffer(uint256 _0xea5edb);


    event AllocatedETHToLiquidityBuffer(uint256 _0xea5edb);
}


contract Staking is Initializable, AccessControlEnumerableUpgradeable, IStaking, StakingEvents, ProtocolEvents {

    error DoesNotReceiveETH();
    error InvalidConfiguration();
    error MaximumValidatorDepositExceeded();
    error MaximumMETHSupplyExceeded();
    error MinimumStakeBoundNotSatisfied();
    error MinimumUnstakeBoundNotSatisfied();
    error MinimumValidatorDepositNotSatisfied();
    error NotEnoughDepositETH();
    error NotEnoughUnallocatedETH();
    error NotReturnsAggregator();
    error NotLiquidityBuffer();
    error NotUnstakeRequestsManager();
    error Paused();
    error PreviouslyUsedValidator();
    error ZeroAddress();
    error InvalidDepositRoot(bytes32);
    error StakeBelowMinimumMETHAmount(uint256 _0xf6329e, uint256 _0xba68fb);
    error UnstakeBelowMinimumETHAmount(uint256 _0xb269de, uint256 _0xba68fb);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x7c63c3("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x7c63c3("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x7c63c3("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x7c63c3("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x7c63c3("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x7c63c3("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x435b41;
        uint256 _0x1dfd89;
        bytes _0xf2101e;
        bytes _0x5f8441;
        bytes _0x243c6e;
        bytes32 _0x814c3d;
    }

    mapping(bytes _0xf2101e => bool _0x2a8e64) public _0xd94521;
    uint256 public _0xd23671;
    uint256 public _0x52fa22;
    uint256 public _0x35291b;
    uint256 public _0xb26ff8;
    uint256 public _0x2e2e08;
    uint256 public _0x653fef;
    uint16 public _0x956a2a;
    uint16 internal constant _0x919d2f = 10_000;
    uint16 internal constant _0xc8cd20 = _0x919d2f / 10;
    uint256 public _0x4f1edb;
    uint256 public _0xa3d910;
    IDepositContract public _0x34a315;
    IMETH public _0x934e4a;
    IOracleReadRecord public _0x8b31bd;
    IPauserRead public _0xb1261c;
    IUnstakeRequestsManager public _0xe0a9a8;
    address public _0x00c356;
    address public _0x7b180a;
    bool public _0xa79c3c;
    uint256 public _0x346cee;
    uint256 public _0xa92d36;
    ILiquidityBuffer public _0x688e87;

    struct Init {
        address _0x1d2f98;
        address _0x9a31e0;
        address _0xad00ff;
        address _0xa6e606;
        address _0x7b180a;
        address _0x00c356;
        IMETH _0x934e4a;
        IDepositContract _0x34a315;
        IOracleReadRecord _0x8b31bd;
        IPauserRead _0xb1261c;
        IUnstakeRequestsManager _0xe0a9a8;
    }

    constructor() {
        _0x7bb74d();
    }

    function _0x83c490(Init memory _0x6b6ff2) external _0x98adae {
        __AccessControlEnumerable_init();

        _0x85419a(DEFAULT_ADMIN_ROLE, _0x6b6ff2._0x1d2f98);
        _0x85419a(STAKING_MANAGER_ROLE, _0x6b6ff2._0x9a31e0);
        _0x85419a(ALLOCATOR_SERVICE_ROLE, _0x6b6ff2._0xad00ff);
        _0x85419a(INITIATOR_SERVICE_ROLE, _0x6b6ff2._0xa6e606);

        _0x421b84(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0x421b84(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        if (block.timestamp > 0) { _0x934e4a = _0x6b6ff2._0x934e4a; }
        _0x34a315 = _0x6b6ff2._0x34a315;
        _0x8b31bd = _0x6b6ff2._0x8b31bd;
        _0xb1261c = _0x6b6ff2._0xb1261c;
        _0x7b180a = _0x6b6ff2._0x7b180a;
        _0xe0a9a8 = _0x6b6ff2._0xe0a9a8;
        _0x00c356 = _0x6b6ff2._0x00c356;

        _0x2e2e08 = 0.1 ether;
        if (gasleft() > 0) { _0x653fef = 0.01 ether; }
        if (true) { _0x4f1edb = 32 ether; }
        _0xa3d910 = 32 ether;
        if (block.timestamp > 0) { _0xa79c3c = true; }
        _0x346cee = block.number;
        _0xa92d36 = 1024 ether;
    }

    function _0xec551b(ILiquidityBuffer _0xfa5b2c) public _0x1f4c57(2) {
        _0x688e87 = _0xfa5b2c;
    }

    function _0x63f0bd(uint256 _0x5407b8) external payable {
        if (_0xb1261c._0x6f5e5d()) {
            revert Paused();
        }

        if (_0xa79c3c) {
            _0x7fe3ef(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x2e2e08) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0xc6477d = _0x07ee51(msg.value);
        if (_0xc6477d + _0x934e4a._0xbeb915() > _0xa92d36) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0xc6477d < _0x5407b8) {
            revert StakeBelowMinimumMETHAmount(_0xc6477d, _0x5407b8);
        }

        _0x35291b += msg.value;

        emit Staked(msg.sender, msg.value, _0xc6477d);
        _0x934e4a._0xfc1982(msg.sender, _0xc6477d);
    }

    function _0x1d1ed3(uint128 _0xf6329e, uint128 _0x558fca) external returns (uint256) {
        return _0xf87bf8(_0xf6329e, _0x558fca);
    }

    function _0x1c99f5(
        uint128 _0xf6329e,
        uint128 _0x558fca,
        uint256 _0x383115,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x97bca3(_0x934e4a, msg.sender, address(this), _0xf6329e, _0x383115, v, r, s);
        return _0xf87bf8(_0xf6329e, _0x558fca);
    }

    function _0xf87bf8(uint128 _0xf6329e, uint128 _0x558fca) internal returns (uint256) {
        if (_0xb1261c._0x602f2c()) {
            revert Paused();
        }

        if (_0xf6329e < _0x653fef) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0xb269de = uint128(_0x7de810(_0xf6329e));
        if (_0xb269de < _0x558fca) {
            revert UnstakeBelowMinimumETHAmount(_0xb269de, _0x558fca);
        }

        uint256 _0xfab70e =
            _0xe0a9a8._0xdeff66({_0x1d85ca: msg.sender, _0x804d1e: _0xf6329e, _0x89fd0b: _0xb269de});
        emit UnstakeRequested({_0xabb4dd: _0xfab70e, _0x7ca589: msg.sender, _0xb269de: _0xb269de, _0x804d1e: _0xf6329e});

        SafeERC20Upgradeable._0x5f75f7(_0x934e4a, msg.sender, address(_0xe0a9a8), _0xf6329e);

        return _0xfab70e;
    }

    function _0x07ee51(uint256 _0xb269de) public view returns (uint256) {
        if (_0x934e4a._0xbeb915() == 0) {
            return _0xb269de;
        }
        uint256 _0x8596e7 = Math._0x6af424(
            _0x3d94f5(), _0x919d2f + _0x956a2a, _0x919d2f
        );
        return Math._0x6af424(_0xb269de, _0x934e4a._0xbeb915(), _0x8596e7);
    }

    function _0x7de810(uint256 _0xf800e2) public view returns (uint256) {
        if (_0x934e4a._0xbeb915() == 0) {
            return _0xf800e2;
        }
        return Math._0x6af424(_0xf800e2, _0x3d94f5(), _0x934e4a._0xbeb915());
    }

    function _0x3d94f5() public view returns (uint256) {
        OracleRecord memory _0x3f09df = _0x8b31bd._0xe6a5be();
        uint256 _0x88eb13 = 0;
        _0x88eb13 += _0x35291b;
        _0x88eb13 += _0xb26ff8;
        _0x88eb13 += _0xd23671 - _0x3f09df._0x65a275;
        _0x88eb13 += _0x3f09df._0x9b84cc;
        _0x88eb13 += _0x688e87._0xed0a8d();
        _0x88eb13 -= _0x688e87._0x128fb2();
        _0x88eb13 += _0xe0a9a8.balance();
        return _0x88eb13;
    }

    function _0x8a70f7() external payable _0x19f96d {
        emit ReturnsReceived(msg.value);
        _0x35291b += msg.value;
    }

    function _0x5e438a() external payable _0xa8346f {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0x35291b += msg.value;
    }

    modifier _0x19f96d() {
        if (msg.sender != _0x7b180a) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0xa8346f() {
        if (msg.sender != address(_0x688e87)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x1cb762() {
        if (msg.sender != address(_0xe0a9a8)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x8e517c(address _0x0bb58a) {
        if (_0x0bb58a == address(0)) {
            revert ZeroAddress();
        }
        _;
    }

    receive() external payable {
        revert DoesNotReceiveETH();
    }

    fallback() external payable {
        revert DoesNotReceiveETH();
    }
}