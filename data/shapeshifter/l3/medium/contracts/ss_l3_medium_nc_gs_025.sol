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

    event Staked(address indexed _0xf69d2c, uint256 _0xafb3db, uint256 _0x0a5001);


    event UnstakeRequested(uint256 indexed _0xc0e250, address indexed _0xf69d2c, uint256 _0xafb3db, uint256 _0x00bb58);


    event UnstakeRequestClaimed(uint256 indexed _0xc0e250, address indexed _0xf69d2c);


    event ValidatorInitiated(bytes32 indexed _0xc0e250, uint256 indexed _0x0e2399, bytes _0x3ed484, uint256 _0x40d3fb);


    event AllocatedETHToUnstakeRequestsManager(uint256 _0x5edb15);


    event AllocatedETHToDeposits(uint256 _0x5edb15);


    event ReturnsReceived(uint256 _0x5edb15);


    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x5edb15);


    event AllocatedETHToLiquidityBuffer(uint256 _0x5edb15);
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
    error StakeBelowMinimumMETHAmount(uint256 _0x4c98ed, uint256 _0x9d3231);
    error UnstakeBelowMinimumETHAmount(uint256 _0xafb3db, uint256 _0x9d3231);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x6b884a("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x6b884a("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x6b884a("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x6b884a("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x6b884a("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x6b884a("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x0e2399;
        uint256 _0xdd3e49;
        bytes _0x3ed484;
        bytes _0xc21424;
        bytes _0x3b8b10;
        bytes32 _0x406c33;
    }

    mapping(bytes _0x3ed484 => bool _0x75e31a) public _0x761d4d;
    uint256 public _0x90b887;
    uint256 public _0xd120fb;
    uint256 public _0x0aa3fb;
    uint256 public _0x981f08;
    uint256 public _0x16a381;
    uint256 public _0x07b5d3;
    uint16 public _0x226132;
    uint16 internal constant _0xa8eac9 = 10_000;
    uint16 internal constant _0xc16f6e = _0xa8eac9 / 10;
    uint256 public _0x2db8b9;
    uint256 public _0xc955d6;
    IDepositContract public _0x7f93d4;
    IMETH public _0x4cb5a8;
    IOracleReadRecord public _0xab0114;
    IPauserRead public _0x9da699;
    IUnstakeRequestsManager public _0xe2803f;
    address public _0x28a8ff;
    address public _0xf185c3;
    bool public _0x55f11a;
    uint256 public _0x27e198;
    uint256 public _0x5331c3;
    ILiquidityBuffer public _0xb2b8f8;

    struct Init {
        address _0x1728df;
        address _0xda78c7;
        address _0x8380cb;
        address _0x90bc5c;
        address _0xf185c3;
        address _0x28a8ff;
        IMETH _0x4cb5a8;
        IDepositContract _0x7f93d4;
        IOracleReadRecord _0xab0114;
        IPauserRead _0x9da699;
        IUnstakeRequestsManager _0xe2803f;
    }

    constructor() {
        _0xab3088();
    }

    function _0xf30796(Init memory _0x78b288) external _0xf3602e {
        __AccessControlEnumerable_init();

        _0x914aeb(DEFAULT_ADMIN_ROLE, _0x78b288._0x1728df);
        _0x914aeb(STAKING_MANAGER_ROLE, _0x78b288._0xda78c7);
        _0x914aeb(ALLOCATOR_SERVICE_ROLE, _0x78b288._0x8380cb);
        _0x914aeb(INITIATOR_SERVICE_ROLE, _0x78b288._0x90bc5c);

        _0xcee984(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xcee984(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x4cb5a8 = _0x78b288._0x4cb5a8; }
        _0x7f93d4 = _0x78b288._0x7f93d4;
        _0xab0114 = _0x78b288._0xab0114;
        if (block.timestamp > 0) { _0x9da699 = _0x78b288._0x9da699; }
        _0xf185c3 = _0x78b288._0xf185c3;
        _0xe2803f = _0x78b288._0xe2803f;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x28a8ff = _0x78b288._0x28a8ff; }

        _0x16a381 = 0.1 ether;
        if (block.timestamp > 0) { _0x07b5d3 = 0.01 ether; }
        _0x2db8b9 = 32 ether;
        if (1 == 1) { _0xc955d6 = 32 ether; }
        _0x55f11a = true;
        _0x27e198 = block.number;
        _0x5331c3 = 1024 ether;
    }

    function _0xa9fe59(ILiquidityBuffer _0x7c574f) public _0xfa17a0(2) {
        _0xb2b8f8 = _0x7c574f;
    }

    function _0x5f29de(uint256 _0x80e626) external payable {
        if (_0x9da699._0xe5c841()) {
            revert Paused();
        }

        if (_0x55f11a) {
            _0x45bf29(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x16a381) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x782a4a = _0xb331fd(msg.value);
        if (_0x782a4a + _0x4cb5a8._0xe472d7() > _0x5331c3) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x782a4a < _0x80e626) {
            revert StakeBelowMinimumMETHAmount(_0x782a4a, _0x80e626);
        }

        _0x0aa3fb += msg.value;

        emit Staked(msg.sender, msg.value, _0x782a4a);
        _0x4cb5a8._0xa4ad83(msg.sender, _0x782a4a);
    }

    function _0x201bca(uint128 _0x4c98ed, uint128 _0xe74b6f) external returns (uint256) {
        return _0x975a56(_0x4c98ed, _0xe74b6f);
    }

    function _0xc05add(
        uint128 _0x4c98ed,
        uint128 _0xe74b6f,
        uint256 _0x609fc5,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x897a90(_0x4cb5a8, msg.sender, address(this), _0x4c98ed, _0x609fc5, v, r, s);
        return _0x975a56(_0x4c98ed, _0xe74b6f);
    }

    function _0x975a56(uint128 _0x4c98ed, uint128 _0xe74b6f) internal returns (uint256) {
        if (_0x9da699._0x4ea0db()) {
            revert Paused();
        }

        if (_0x4c98ed < _0x07b5d3) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0xafb3db = uint128(_0x8c2501(_0x4c98ed));
        if (_0xafb3db < _0xe74b6f) {
            revert UnstakeBelowMinimumETHAmount(_0xafb3db, _0xe74b6f);
        }

        uint256 _0xf33b86 =
            _0xe2803f._0xa7c5b1({_0x3d52df: msg.sender, _0x00bb58: _0x4c98ed, _0x6e42cf: _0xafb3db});
        emit UnstakeRequested({_0xc0e250: _0xf33b86, _0xf69d2c: msg.sender, _0xafb3db: _0xafb3db, _0x00bb58: _0x4c98ed});

        SafeERC20Upgradeable._0x886779(_0x4cb5a8, msg.sender, address(_0xe2803f), _0x4c98ed);

        return _0xf33b86;
    }

    function _0xb331fd(uint256 _0xafb3db) public view returns (uint256) {
        if (_0x4cb5a8._0xe472d7() == 0) {
            return _0xafb3db;
        }
        uint256 _0x970fca = Math._0x5ce468(
            _0x2a4820(), _0xa8eac9 + _0x226132, _0xa8eac9
        );
        return Math._0x5ce468(_0xafb3db, _0x4cb5a8._0xe472d7(), _0x970fca);
    }

    function _0x8c2501(uint256 _0x0a5001) public view returns (uint256) {
        if (_0x4cb5a8._0xe472d7() == 0) {
            return _0x0a5001;
        }
        return Math._0x5ce468(_0x0a5001, _0x2a4820(), _0x4cb5a8._0xe472d7());
    }

    function _0x2a4820() public view returns (uint256) {
        OracleRecord memory _0xf6fe14 = _0xab0114._0x3be53e();
        uint256 _0xdc9861 = 0;
        _0xdc9861 += _0x0aa3fb;
        _0xdc9861 += _0x981f08;
        _0xdc9861 += _0x90b887 - _0xf6fe14._0x4f96e2;
        _0xdc9861 += _0xf6fe14._0x3e0112;
        _0xdc9861 += _0xb2b8f8._0x7d71e6();
        _0xdc9861 -= _0xb2b8f8._0xe0aef0();
        _0xdc9861 += _0xe2803f.balance();
        return _0xdc9861;
    }

    function _0x5614d9() external payable _0xf540a1 {
        emit ReturnsReceived(msg.value);
        _0x0aa3fb += msg.value;
    }

    function _0x77b522() external payable _0x16ddde {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0x0aa3fb += msg.value;
    }

    modifier _0xf540a1() {
        if (msg.sender != _0xf185c3) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x16ddde() {
        if (msg.sender != address(_0xb2b8f8)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x4145fe() {
        if (msg.sender != address(_0xe2803f)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x6283bc(address _0xbf9346) {
        if (_0xbf9346 == address(0)) {
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