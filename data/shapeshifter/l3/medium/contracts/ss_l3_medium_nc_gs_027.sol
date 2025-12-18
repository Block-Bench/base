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

    event Staked(address indexed _0x4de2e5, uint256 _0xf6062b, uint256 _0x9a42b1);


    event UnstakeRequested(uint256 indexed _0x7b7e5d, address indexed _0x4de2e5, uint256 _0xf6062b, uint256 _0x3437a8);


    event UnstakeRequestClaimed(uint256 indexed _0x7b7e5d, address indexed _0x4de2e5);


    event ValidatorInitiated(bytes32 indexed _0x7b7e5d, uint256 indexed _0xae89ab, bytes _0xa83f51, uint256 _0xb6f0f4);


    event AllocatedETHToUnstakeRequestsManager(uint256 _0x34577a);


    event AllocatedETHToDeposits(uint256 _0x34577a);


    event ReturnsReceived(uint256 _0x34577a);


    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x34577a);


    event AllocatedETHToLiquidityBuffer(uint256 _0x34577a);
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
    error StakeBelowMinimumMETHAmount(uint256 _0xa001c6, uint256 _0x027bde);
    error UnstakeBelowMinimumETHAmount(uint256 _0xf6062b, uint256 _0x027bde);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0xc08a19("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0xc08a19("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0xc08a19("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0xc08a19("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0xc08a19("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0xc08a19("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0xae89ab;
        uint256 _0x114ef9;
        bytes _0xa83f51;
        bytes _0x334afa;
        bytes _0x133d63;
        bytes32 _0x1ce30c;
    }

    mapping(bytes _0xa83f51 => bool _0x824187) public _0x2dbd6c;
    uint256 public _0x69163b;
    uint256 public _0xfc7c1a;
    uint256 public _0xf04fa2;
    uint256 public _0x20f137;
    uint256 public _0xa57c76;
    uint256 public _0x38c529;
    uint16 public _0xc39a9e;
    uint16 internal constant _0x85744f = 10_000;
    uint16 internal constant _0xe7b499 = _0x85744f / 10;
    uint256 public _0x7e80ac;
    uint256 public _0x17c085;
    IDepositContract public _0x9b908b;
    IMETH public _0x607205;
    IOracleReadRecord public _0x5c92f7;
    IPauserRead public _0xa6643c;
    IUnstakeRequestsManager public _0x3f77cc;
    address public _0x120d29;
    address public _0xe83b32;
    bool public _0xc7a242;
    uint256 public _0xd94e3c;
    uint256 public _0x413e12;
    ILiquidityBuffer public _0x14070e;

    struct Init {
        address _0x7fad40;
        address _0xd6fcd8;
        address _0xaa61ca;
        address _0x49ad72;
        address _0xe83b32;
        address _0x120d29;
        IMETH _0x607205;
        IDepositContract _0x9b908b;
        IOracleReadRecord _0x5c92f7;
        IPauserRead _0xa6643c;
        IUnstakeRequestsManager _0x3f77cc;
    }

    constructor() {
        _0x74c463();
    }

    function _0x17f896(Init memory _0x5dbcb8) external _0x7c8342 {
        __AccessControlEnumerable_init();

        _0x577e34(DEFAULT_ADMIN_ROLE, _0x5dbcb8._0x7fad40);
        _0x577e34(STAKING_MANAGER_ROLE, _0x5dbcb8._0xd6fcd8);
        _0x577e34(ALLOCATOR_SERVICE_ROLE, _0x5dbcb8._0xaa61ca);
        _0x577e34(INITIATOR_SERVICE_ROLE, _0x5dbcb8._0x49ad72);

        _0xdde095(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xdde095(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0x607205 = _0x5dbcb8._0x607205;
        _0x9b908b = _0x5dbcb8._0x9b908b;
        _0x5c92f7 = _0x5dbcb8._0x5c92f7;
        if (true) { _0xa6643c = _0x5dbcb8._0xa6643c; }
        _0xe83b32 = _0x5dbcb8._0xe83b32;
        _0x3f77cc = _0x5dbcb8._0x3f77cc;
        _0x120d29 = _0x5dbcb8._0x120d29;

        if (1 == 1) { _0xa57c76 = 0.1 ether; }
        _0x38c529 = 0.01 ether;
        _0x7e80ac = 32 ether;
        _0x17c085 = 32 ether;
        if (gasleft() > 0) { _0xc7a242 = true; }
        _0xd94e3c = block.number;
        if (true) { _0x413e12 = 1024 ether; }
    }

    function _0x45ab4b(ILiquidityBuffer _0x84c0b4) public _0x1ab03e(2) {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x14070e = _0x84c0b4; }
    }

    function _0x021901(uint256 _0xd6ffc8) external payable {
        if (_0xa6643c._0x85a126()) {
            revert Paused();
        }

        if (_0xc7a242) {
            _0xdd54f1(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0xa57c76) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0xcd0474 = _0xb2efb5(msg.value);
        if (_0xcd0474 + _0x607205._0x519e1b() > _0x413e12) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0xcd0474 < _0xd6ffc8) {
            revert StakeBelowMinimumMETHAmount(_0xcd0474, _0xd6ffc8);
        }

        _0xf04fa2 += msg.value;

        emit Staked(msg.sender, msg.value, _0xcd0474);
        _0x607205._0xa5911c(msg.sender, _0xcd0474);
    }

    function _0x41e3b3(uint128 _0xa001c6, uint128 _0x74f40f) external returns (uint256) {
        return _0xe76b94(_0xa001c6, _0x74f40f);
    }

    function _0xf5590a(
        uint128 _0xa001c6,
        uint128 _0x74f40f,
        uint256 _0xb5ff8c,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x94fe45(_0x607205, msg.sender, address(this), _0xa001c6, _0xb5ff8c, v, r, s);
        return _0xe76b94(_0xa001c6, _0x74f40f);
    }

    function _0xe76b94(uint128 _0xa001c6, uint128 _0x74f40f) internal returns (uint256) {
        if (_0xa6643c._0x2dc779()) {
            revert Paused();
        }

        if (_0xa001c6 < _0x38c529) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0xf6062b = uint128(_0x312802(_0xa001c6));
        if (_0xf6062b < _0x74f40f) {
            revert UnstakeBelowMinimumETHAmount(_0xf6062b, _0x74f40f);
        }

        uint256 _0x921c57 =
            _0x3f77cc._0xee2b0f({_0x9fc643: msg.sender, _0x3437a8: _0xa001c6, _0x8aa7d1: _0xf6062b});
        emit UnstakeRequested({_0x7b7e5d: _0x921c57, _0x4de2e5: msg.sender, _0xf6062b: _0xf6062b, _0x3437a8: _0xa001c6});

        SafeERC20Upgradeable._0x810527(_0x607205, msg.sender, address(_0x3f77cc), _0xa001c6);

        return _0x921c57;
    }

    function _0xb2efb5(uint256 _0xf6062b) public view returns (uint256) {
        if (_0x607205._0x519e1b() == 0) {
            return _0xf6062b;
        }
        uint256 _0x7e18ef = Math._0xee3a2e(
            _0xd64aad(), _0x85744f + _0xc39a9e, _0x85744f
        );
        return Math._0xee3a2e(_0xf6062b, _0x607205._0x519e1b(), _0x7e18ef);
    }

    function _0x312802(uint256 _0x9a42b1) public view returns (uint256) {
        if (_0x607205._0x519e1b() == 0) {
            return _0x9a42b1;
        }
        return Math._0xee3a2e(_0x9a42b1, _0xd64aad(), _0x607205._0x519e1b());
    }

    function _0xd64aad() public view returns (uint256) {
        OracleRecord memory _0x5829a4 = _0x5c92f7._0x890b95();
        uint256 _0xbc2553 = 0;
        _0xbc2553 += _0xf04fa2;
        _0xbc2553 += _0x20f137;
        _0xbc2553 += _0x69163b - _0x5829a4._0x1882f2;
        _0xbc2553 += _0x5829a4._0xf2dc69;
        _0xbc2553 += _0x14070e._0xc927d1();
        _0xbc2553 -= _0x14070e._0x105487();
        _0xbc2553 += _0x3f77cc.balance();
        return _0xbc2553;
    }

    function _0x84a14b() external payable _0xcde518 {
        emit ReturnsReceived(msg.value);
        _0xf04fa2 += msg.value;
    }

    function _0x1e58a3() external payable _0x295d1d {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xf04fa2 += msg.value;
    }

    modifier _0xcde518() {
        if (msg.sender != _0xe83b32) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x295d1d() {
        if (msg.sender != address(_0x14070e)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0xe09360() {
        if (msg.sender != address(_0x3f77cc)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0xc0974a(address _0x396dc9) {
        if (_0x396dc9 == address(0)) {
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