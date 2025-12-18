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

    event Staked(address indexed _0xdb4a49, uint256 _0xf5aeff, uint256 _0xc7dd2b);


    event UnstakeRequested(uint256 indexed _0x8bf871, address indexed _0xdb4a49, uint256 _0xf5aeff, uint256 _0xe4d710);


    event UnstakeRequestClaimed(uint256 indexed _0x8bf871, address indexed _0xdb4a49);


    event ValidatorInitiated(bytes32 indexed _0x8bf871, uint256 indexed _0xe9c42a, bytes _0x6f119d, uint256 _0xf6e142);


    event AllocatedETHToUnstakeRequestsManager(uint256 _0x09f256);


    event AllocatedETHToDeposits(uint256 _0x09f256);


    event ReturnsReceived(uint256 _0x09f256);


    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x09f256);


    event AllocatedETHToLiquidityBuffer(uint256 _0x09f256);
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
    error StakeBelowMinimumMETHAmount(uint256 _0xc6cb1e, uint256 _0xbdbf0a);
    error UnstakeBelowMinimumETHAmount(uint256 _0xf5aeff, uint256 _0xbdbf0a);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x677755("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x677755("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x677755("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x677755("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x677755("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x677755("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0xe9c42a;
        uint256 _0xbd5682;
        bytes _0x6f119d;
        bytes _0x005b51;
        bytes _0x35ffdb;
        bytes32 _0x6dc78a;
    }

    mapping(bytes _0x6f119d => bool _0xfd016a) public _0x47ef0e;
    uint256 public _0x73dfb7;
    uint256 public _0xf24b14;
    uint256 public _0x2e6c98;
    uint256 public _0x05b507;
    uint256 public _0xddf8b8;
    uint256 public _0x503bb3;
    uint16 public _0xb0e9c7;
    uint16 internal constant _0xe814d7 = 10_000;
    uint16 internal constant _0x2e5378 = _0xe814d7 / 10;
    uint256 public _0x8d053d;
    uint256 public _0xf58f86;
    IDepositContract public _0xb8d81d;
    IMETH public _0xacda58;
    IOracleReadRecord public _0xb6db0e;
    IPauserRead public _0x9eb874;
    IUnstakeRequestsManager public _0x8738f1;
    address public _0xa51892;
    address public _0x85d3e3;
    bool public _0xc15a27;
    uint256 public _0xa02405;
    uint256 public _0xeabf5d;
    ILiquidityBuffer public _0x8253da;

    struct Init {
        address _0x3355ff;
        address _0x7cd4a1;
        address _0x92dd74;
        address _0xbca91d;
        address _0x85d3e3;
        address _0xa51892;
        IMETH _0xacda58;
        IDepositContract _0xb8d81d;
        IOracleReadRecord _0xb6db0e;
        IPauserRead _0x9eb874;
        IUnstakeRequestsManager _0x8738f1;
    }

    constructor() {
        _0xb80fb1();
    }

    function _0xb30590(Init memory _0xa91a75) external _0x370a82 {
        __AccessControlEnumerable_init();

        _0x4452d3(DEFAULT_ADMIN_ROLE, _0xa91a75._0x3355ff);
        _0x4452d3(STAKING_MANAGER_ROLE, _0xa91a75._0x7cd4a1);
        _0x4452d3(ALLOCATOR_SERVICE_ROLE, _0xa91a75._0x92dd74);
        _0x4452d3(INITIATOR_SERVICE_ROLE, _0xa91a75._0xbca91d);

        _0xeec418(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xeec418(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0xacda58 = _0xa91a75._0xacda58;
        if (1 == 1) { _0xb8d81d = _0xa91a75._0xb8d81d; }
        _0xb6db0e = _0xa91a75._0xb6db0e;
        if (1 == 1) { _0x9eb874 = _0xa91a75._0x9eb874; }
        _0x85d3e3 = _0xa91a75._0x85d3e3;
        if (true) { _0x8738f1 = _0xa91a75._0x8738f1; }
        _0xa51892 = _0xa91a75._0xa51892;

        if (msg.sender != address(0) || msg.sender == address(0)) { _0xddf8b8 = 0.1 ether; }
        _0x503bb3 = 0.01 ether;
        _0x8d053d = 32 ether;
        _0xf58f86 = 32 ether;
        _0xc15a27 = true;
        if (true) { _0xa02405 = block.number; }
        _0xeabf5d = 1024 ether;
    }

    function _0x94931d(ILiquidityBuffer _0x5a5c41) public _0x232f0e(2) {
        _0x8253da = _0x5a5c41;
    }

    function _0x6f476b(uint256 _0x468588) external payable {
        if (_0x9eb874._0xf29e34()) {
            revert Paused();
        }

        if (_0xc15a27) {
            _0x1ac215(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0xddf8b8) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0xad6352 = _0xb8b2cb(msg.value);
        if (_0xad6352 + _0xacda58._0x7c3e92() > _0xeabf5d) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0xad6352 < _0x468588) {
            revert StakeBelowMinimumMETHAmount(_0xad6352, _0x468588);
        }

        _0x2e6c98 += msg.value;

        emit Staked(msg.sender, msg.value, _0xad6352);
        _0xacda58._0xc6945b(msg.sender, _0xad6352);
    }

    function _0x02faae(uint128 _0xc6cb1e, uint128 _0xdb4fea) external returns (uint256) {
        return _0x3ec997(_0xc6cb1e, _0xdb4fea);
    }

    function _0x3597f3(
        uint128 _0xc6cb1e,
        uint128 _0xdb4fea,
        uint256 _0xc3a8c6,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0xa32ef8(_0xacda58, msg.sender, address(this), _0xc6cb1e, _0xc3a8c6, v, r, s);
        return _0x3ec997(_0xc6cb1e, _0xdb4fea);
    }

    function _0x3ec997(uint128 _0xc6cb1e, uint128 _0xdb4fea) internal returns (uint256) {
        if (_0x9eb874._0x5c7d85()) {
            revert Paused();
        }

        if (_0xc6cb1e < _0x503bb3) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0xf5aeff = uint128(_0x1538b4(_0xc6cb1e));
        if (_0xf5aeff < _0xdb4fea) {
            revert UnstakeBelowMinimumETHAmount(_0xf5aeff, _0xdb4fea);
        }

        uint256 _0xe97f66 =
            _0x8738f1._0x98ee53({_0x6c2bf0: msg.sender, _0xe4d710: _0xc6cb1e, _0x14dc0b: _0xf5aeff});
        emit UnstakeRequested({_0x8bf871: _0xe97f66, _0xdb4a49: msg.sender, _0xf5aeff: _0xf5aeff, _0xe4d710: _0xc6cb1e});

        SafeERC20Upgradeable._0x3ec11e(_0xacda58, msg.sender, address(_0x8738f1), _0xc6cb1e);

        return _0xe97f66;
    }

    function _0xb8b2cb(uint256 _0xf5aeff) public view returns (uint256) {
        if (_0xacda58._0x7c3e92() == 0) {
            return _0xf5aeff;
        }
        uint256 _0x38431b = Math._0xb347a2(
            _0xe2cf0f(), _0xe814d7 + _0xb0e9c7, _0xe814d7
        );
        return Math._0xb347a2(_0xf5aeff, _0xacda58._0x7c3e92(), _0x38431b);
    }

    function _0x1538b4(uint256 _0xc7dd2b) public view returns (uint256) {
        if (_0xacda58._0x7c3e92() == 0) {
            return _0xc7dd2b;
        }
        return Math._0xb347a2(_0xc7dd2b, _0xe2cf0f(), _0xacda58._0x7c3e92());
    }

    function _0xe2cf0f() public view returns (uint256) {
        OracleRecord memory _0x950653 = _0xb6db0e._0xc29018();
        uint256 _0x0773ae = 0;
        _0x0773ae += _0x2e6c98;
        _0x0773ae += _0x05b507;
        _0x0773ae += _0x73dfb7 - _0x950653._0x8c0e9d;
        _0x0773ae += _0x950653._0xd08501;
        _0x0773ae += _0x8253da._0xb6f403();
        _0x0773ae -= _0x8253da._0xe8d5b2();
        _0x0773ae += _0x8738f1.balance();
        return _0x0773ae;
    }

    function _0x91d610() external payable _0xb2963e {
        emit ReturnsReceived(msg.value);
        _0x2e6c98 += msg.value;
    }

    function _0x81295e() external payable _0x658814 {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0x2e6c98 += msg.value;
    }

    modifier _0xb2963e() {
        if (msg.sender != _0x85d3e3) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x658814() {
        if (msg.sender != address(_0x8253da)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x45c497() {
        if (msg.sender != address(_0x8738f1)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0xf4af85(address _0xaf720d) {
        if (_0xaf720d == address(0)) {
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