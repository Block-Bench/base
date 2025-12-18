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

    event Staked(address indexed _0xdb7cc9, uint256 _0x714c0f, uint256 _0x17bf5c);


    event UnstakeRequested(uint256 indexed _0xb471d7, address indexed _0xdb7cc9, uint256 _0x714c0f, uint256 _0xb15769);


    event UnstakeRequestClaimed(uint256 indexed _0xb471d7, address indexed _0xdb7cc9);


    event ValidatorInitiated(bytes32 indexed _0xb471d7, uint256 indexed _0xe78378, bytes _0x7bf8a1, uint256 _0x866c8b);


    event AllocatedETHToUnstakeRequestsManager(uint256 _0x63c57f);


    event AllocatedETHToDeposits(uint256 _0x63c57f);


    event ReturnsReceived(uint256 _0x63c57f);


    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x63c57f);


    event AllocatedETHToLiquidityBuffer(uint256 _0x63c57f);
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
    error StakeBelowMinimumMETHAmount(uint256 _0x3401af, uint256 _0xe3b4f9);
    error UnstakeBelowMinimumETHAmount(uint256 _0x714c0f, uint256 _0xe3b4f9);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x471644("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x471644("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x471644("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x471644("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x471644("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x471644("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0xe78378;
        uint256 _0x52a8fe;
        bytes _0x7bf8a1;
        bytes _0x423945;
        bytes _0x4e7db9;
        bytes32 _0xa3a395;
    }

    mapping(bytes _0x7bf8a1 => bool _0x35ed4c) public _0x363215;
    uint256 public _0x7ad1f8;
    uint256 public _0x6c8c02;
    uint256 public _0x7e9066;
    uint256 public _0xbecc3f;
    uint256 public _0xd38aa0;
    uint256 public _0x14bbae;
    uint16 public _0xe18da7;
    uint16 internal constant _0x91cc05 = 10_000;
    uint16 internal constant _0x7f046d = _0x91cc05 / 10;
    uint256 public _0x09ce63;
    uint256 public _0x32904f;
    IDepositContract public _0xcb42c1;
    IMETH public _0x4d1407;
    IOracleReadRecord public _0x6e7b71;
    IPauserRead public _0xa00308;
    IUnstakeRequestsManager public _0x9ad84e;
    address public _0xed1570;
    address public _0xeca772;
    bool public _0x6c67ac;
    uint256 public _0x1e4a21;
    uint256 public _0xa4a830;
    ILiquidityBuffer public _0x33d6e9;

    struct Init {
        address _0x36b017;
        address _0x164943;
        address _0xc494d1;
        address _0x22245d;
        address _0xeca772;
        address _0xed1570;
        IMETH _0x4d1407;
        IDepositContract _0xcb42c1;
        IOracleReadRecord _0x6e7b71;
        IPauserRead _0xa00308;
        IUnstakeRequestsManager _0x9ad84e;
    }

    constructor() {
        _0x76ca0a();
    }

    function _0x40bf28(Init memory _0xd2d115) external _0x390490 {
        __AccessControlEnumerable_init();

        _0xf155d0(DEFAULT_ADMIN_ROLE, _0xd2d115._0x36b017);
        _0xf155d0(STAKING_MANAGER_ROLE, _0xd2d115._0x164943);
        _0xf155d0(ALLOCATOR_SERVICE_ROLE, _0xd2d115._0xc494d1);
        _0xf155d0(INITIATOR_SERVICE_ROLE, _0xd2d115._0x22245d);

        _0xd84559(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xd84559(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x4d1407 = _0xd2d115._0x4d1407; }
        _0xcb42c1 = _0xd2d115._0xcb42c1;
        _0x6e7b71 = _0xd2d115._0x6e7b71;
        _0xa00308 = _0xd2d115._0xa00308;
        _0xeca772 = _0xd2d115._0xeca772;
        _0x9ad84e = _0xd2d115._0x9ad84e;
        _0xed1570 = _0xd2d115._0xed1570;

        _0xd38aa0 = 0.1 ether;
        _0x14bbae = 0.01 ether;
        if (gasleft() > 0) { _0x09ce63 = 32 ether; }
        _0x32904f = 32 ether;
        if (1 == 1) { _0x6c67ac = true; }
        _0x1e4a21 = block.number;
        _0xa4a830 = 1024 ether;
    }

    function _0x54549e(ILiquidityBuffer _0xcb3a01) public _0xf36211(2) {
        _0x33d6e9 = _0xcb3a01;
    }

    function _0xeee3e9(uint256 _0xc74a85) external payable {
        if (_0xa00308._0x48a7cd()) {
            revert Paused();
        }

        if (_0x6c67ac) {
            _0x9a49a4(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0xd38aa0) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x0a7211 = _0xf399de(msg.value);
        if (_0x0a7211 + _0x4d1407._0xa8b163() > _0xa4a830) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x0a7211 < _0xc74a85) {
            revert StakeBelowMinimumMETHAmount(_0x0a7211, _0xc74a85);
        }

        _0x7e9066 += msg.value;

        emit Staked(msg.sender, msg.value, _0x0a7211);
        _0x4d1407._0xd5b550(msg.sender, _0x0a7211);
    }

    function _0x041f90(uint128 _0x3401af, uint128 _0x782cd6) external returns (uint256) {
        return _0xec1ac9(_0x3401af, _0x782cd6);
    }

    function _0x1d0b07(
        uint128 _0x3401af,
        uint128 _0x782cd6,
        uint256 _0x1e0c38,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x7926b1(_0x4d1407, msg.sender, address(this), _0x3401af, _0x1e0c38, v, r, s);
        return _0xec1ac9(_0x3401af, _0x782cd6);
    }

    function _0xec1ac9(uint128 _0x3401af, uint128 _0x782cd6) internal returns (uint256) {
        if (_0xa00308._0x16bb11()) {
            revert Paused();
        }

        if (_0x3401af < _0x14bbae) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x714c0f = uint128(_0xf80cd6(_0x3401af));
        if (_0x714c0f < _0x782cd6) {
            revert UnstakeBelowMinimumETHAmount(_0x714c0f, _0x782cd6);
        }

        uint256 _0x42c475 =
            _0x9ad84e._0x927720({_0x32468c: msg.sender, _0xb15769: _0x3401af, _0xe97470: _0x714c0f});
        emit UnstakeRequested({_0xb471d7: _0x42c475, _0xdb7cc9: msg.sender, _0x714c0f: _0x714c0f, _0xb15769: _0x3401af});

        SafeERC20Upgradeable._0xfba8c3(_0x4d1407, msg.sender, address(_0x9ad84e), _0x3401af);

        return _0x42c475;
    }

    function _0xf399de(uint256 _0x714c0f) public view returns (uint256) {
        if (_0x4d1407._0xa8b163() == 0) {
            return _0x714c0f;
        }
        uint256 _0x4d3ba4 = Math._0x9e4a78(
            _0xd2fbec(), _0x91cc05 + _0xe18da7, _0x91cc05
        );
        return Math._0x9e4a78(_0x714c0f, _0x4d1407._0xa8b163(), _0x4d3ba4);
    }

    function _0xf80cd6(uint256 _0x17bf5c) public view returns (uint256) {
        if (_0x4d1407._0xa8b163() == 0) {
            return _0x17bf5c;
        }
        return Math._0x9e4a78(_0x17bf5c, _0xd2fbec(), _0x4d1407._0xa8b163());
    }

    function _0xd2fbec() public view returns (uint256) {
        OracleRecord memory _0x816e61 = _0x6e7b71._0x0bd845();
        uint256 _0x8b3666 = 0;
        _0x8b3666 += _0x7e9066;
        _0x8b3666 += _0xbecc3f;
        _0x8b3666 += _0x7ad1f8 - _0x816e61._0x4d06c3;
        _0x8b3666 += _0x816e61._0x717319;
        _0x8b3666 += _0x33d6e9._0xd821d8();
        _0x8b3666 -= _0x33d6e9._0x712944();
        _0x8b3666 += _0x9ad84e.balance();
        return _0x8b3666;
    }

    function _0xb08962() external payable _0x6cfbe6 {
        emit ReturnsReceived(msg.value);
        _0x7e9066 += msg.value;
    }

    function _0xc8bffc() external payable _0xff8e2e {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0x7e9066 += msg.value;
    }

    modifier _0x6cfbe6() {
        if (msg.sender != _0xeca772) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0xff8e2e() {
        if (msg.sender != address(_0x33d6e9)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x00f477() {
        if (msg.sender != address(_0x9ad84e)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x5bdbbd(address _0x004bb9) {
        if (_0x004bb9 == address(0)) {
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