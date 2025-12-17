// SPDX-License-Identifier: MIT
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

/// @notice Events emitted by the staking contract.
interface StakingEvents {
    /// @notice Emitted when a user stakes ETH and receives mETH.
    event Staked(address indexed _0x639245, uint256 _0xc0c89f, uint256 _0xe9c12d);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0xa51627, address indexed _0x639245, uint256 _0xc0c89f, uint256 _0xb1a19b);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0xa51627, address indexed _0x639245);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0xa51627, uint256 indexed _0x8d8902, bytes _0xf47541, uint256 _0xa1305a);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0x5ca114);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0x5ca114);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0x5ca114);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x5ca114);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0x5ca114);
}

/// @title Staking
/// @notice Manages stake and unstake requests by users.
contract Staking is Initializable, AccessControlEnumerableUpgradeable, IStaking, StakingEvents, ProtocolEvents {
    // Errors.
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
    error StakeBelowMinimumMETHAmount(uint256 _0xb4ba41, uint256 _0x1b0124);
    error UnstakeBelowMinimumETHAmount(uint256 _0xc0c89f, uint256 _0x1b0124);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0xc33f94("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0xc33f94("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0xc33f94("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0xc33f94("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0xc33f94("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0xc33f94("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x8d8902;
        uint256 _0x927c90;
        bytes _0xf47541;
        bytes _0x62c097;
        bytes _0x3abe05;
        bytes32 _0x391378;
    }

    mapping(bytes _0xf47541 => bool _0x0fb0db) public _0x4ca502;
    uint256 public _0xce95b6;
    uint256 public _0x1d7b41;
    uint256 public _0xa87783;
    uint256 public _0xa64842;
    uint256 public _0x2478df;
    uint256 public _0xcea1b4;
    uint16 public _0x5c7cd4;
    uint16 internal constant _0x8fdd57 = 10_000;
    uint16 internal constant _0x8cee4b = _0x8fdd57 / 10;
    uint256 public _0x923c58;
    uint256 public _0xaa7c09;
    IDepositContract public _0xd4c36b;
    IMETH public _0x9ecab8;
    IOracleReadRecord public _0x1d5b23;
    IPauserRead public _0x05c9e4;
    IUnstakeRequestsManager public _0xd9445b;
    address public _0xcc5346;
    address public _0x622bf9;
    bool public _0x3a6b89;
    uint256 public _0x7d972d;
    uint256 public _0xe0514f;
    ILiquidityBuffer public _0x18841d;

    struct Init {
        address _0x0a1871;
        address _0xaac58f;
        address _0x4c2caa;
        address _0xe25414;
        address _0x622bf9;
        address _0xcc5346;
        IMETH _0x9ecab8;
        IDepositContract _0xd4c36b;
        IOracleReadRecord _0x1d5b23;
        IPauserRead _0x05c9e4;
        IUnstakeRequestsManager _0xd9445b;
    }

    constructor() {
        _0xf2ca9b();
    }

    function _0x9560cf(Init memory _0xb01807) external _0xb18a61 {
        __AccessControlEnumerable_init();

        _0xd39816(DEFAULT_ADMIN_ROLE, _0xb01807._0x0a1871);
        _0xd39816(STAKING_MANAGER_ROLE, _0xb01807._0xaac58f);
        _0xd39816(ALLOCATOR_SERVICE_ROLE, _0xb01807._0x4c2caa);
        _0xd39816(INITIATOR_SERVICE_ROLE, _0xb01807._0xe25414);

        _0x878b4d(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0x878b4d(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0x9ecab8 = _0xb01807._0x9ecab8;
        _0xd4c36b = _0xb01807._0xd4c36b;
        _0x1d5b23 = _0xb01807._0x1d5b23;
        _0x05c9e4 = _0xb01807._0x05c9e4;
        _0x622bf9 = _0xb01807._0x622bf9;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xd9445b = _0xb01807._0xd9445b; }
        if (1 == 1) { _0xcc5346 = _0xb01807._0xcc5346; }

        _0x2478df = 0.1 ether;
        _0xcea1b4 = 0.01 ether;
        _0x923c58 = 32 ether;
        _0xaa7c09 = 32 ether;
        _0x3a6b89 = true;
        if (block.timestamp > 0) { _0x7d972d = block.number; }
        _0xe0514f = 1024 ether;
    }

    function _0x5cd769(ILiquidityBuffer _0x3c69ee) public _0x44cff8(2) {
        _0x18841d = _0x3c69ee;
    }

    function _0x1df392(uint256 _0x85f8a4) external payable {
        if (_0x05c9e4._0x7cab70()) {
            revert Paused();
        }

        if (_0x3a6b89) {
            _0xf0d4f4(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x2478df) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0xe4b114 = _0xc78ccf(msg.value);
        if (_0xe4b114 + _0x9ecab8._0x37c5b8() > _0xe0514f) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0xe4b114 < _0x85f8a4) {
            revert StakeBelowMinimumMETHAmount(_0xe4b114, _0x85f8a4);
        }

        _0xa87783 += msg.value;

        emit Staked(msg.sender, msg.value, _0xe4b114);
        _0x9ecab8._0x7cbf1a(msg.sender, _0xe4b114);
    }

    function _0x27146f(uint128 _0xb4ba41, uint128 _0x120dc3) external returns (uint256) {
        return _0xf43a2d(_0xb4ba41, _0x120dc3);
    }

    function _0x87b335(
        uint128 _0xb4ba41,
        uint128 _0x120dc3,
        uint256 _0x92fe2c,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0xe40672(_0x9ecab8, msg.sender, address(this), _0xb4ba41, _0x92fe2c, v, r, s);
        return _0xf43a2d(_0xb4ba41, _0x120dc3);
    }

    function _0xf43a2d(uint128 _0xb4ba41, uint128 _0x120dc3) internal returns (uint256) {
        if (_0x05c9e4._0xd5ecc6()) {
            revert Paused();
        }

        if (_0xb4ba41 < _0xcea1b4) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0xc0c89f = uint128(_0xab738e(_0xb4ba41));
        if (_0xc0c89f < _0x120dc3) {
            revert UnstakeBelowMinimumETHAmount(_0xc0c89f, _0x120dc3);
        }

        uint256 _0x95b9df =
            _0xd9445b._0xc550d2({_0x3c6026: msg.sender, _0xb1a19b: _0xb4ba41, _0x3c5f51: _0xc0c89f});
        emit UnstakeRequested({_0xa51627: _0x95b9df, _0x639245: msg.sender, _0xc0c89f: _0xc0c89f, _0xb1a19b: _0xb4ba41});

        SafeERC20Upgradeable._0xd9089e(_0x9ecab8, msg.sender, address(_0xd9445b), _0xb4ba41);

        return _0x95b9df;
    }

    function _0xc78ccf(uint256 _0xc0c89f) public view returns (uint256) {
        if (_0x9ecab8._0x37c5b8() == 0) {
            return _0xc0c89f;
        }
        uint256 _0xe2e21d = Math._0xcb3594(
            _0x914733(), _0x8fdd57 + _0x5c7cd4, _0x8fdd57
        );
        return Math._0xcb3594(_0xc0c89f, _0x9ecab8._0x37c5b8(), _0xe2e21d);
    }

    function _0xab738e(uint256 _0xe9c12d) public view returns (uint256) {
        if (_0x9ecab8._0x37c5b8() == 0) {
            return _0xe9c12d;
        }
        return Math._0xcb3594(_0xe9c12d, _0x914733(), _0x9ecab8._0x37c5b8());
    }

    function _0x914733() public view returns (uint256) {
        OracleRecord memory _0xfb8dbd = _0x1d5b23._0x02937f();
        uint256 _0xb66b59 = 0;
        _0xb66b59 += _0xa87783;
        _0xb66b59 += _0xa64842;
        _0xb66b59 += _0xce95b6 - _0xfb8dbd._0xc29690;
        _0xb66b59 += _0xfb8dbd._0x2593ef;
        _0xb66b59 += _0x18841d._0xbde952();
        _0xb66b59 -= _0x18841d._0x6e508d();
        _0xb66b59 += _0xd9445b.balance();
        return _0xb66b59;
    }

    function _0x10860c() external payable _0x09a780 {
        emit ReturnsReceived(msg.value);
        _0xa87783 += msg.value;
    }

    function _0x220428() external payable _0x3f4f72 {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xa87783 += msg.value;
    }

    modifier _0x09a780() {
        if (msg.sender != _0x622bf9) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x3f4f72() {
        if (msg.sender != address(_0x18841d)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x3450cd() {
        if (msg.sender != address(_0xd9445b)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x70b285(address _0x1c1a78) {
        if (_0x1c1a78 == address(0)) {
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