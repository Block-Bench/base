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
    event Staked(address indexed _0x818463, uint256 _0x7f6b37, uint256 _0xb60c38);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0x8b86dd, address indexed _0x818463, uint256 _0x7f6b37, uint256 _0x741278);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0x8b86dd, address indexed _0x818463);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0x8b86dd, uint256 indexed _0xf43133, bytes _0x72c46a, uint256 _0x8f40bc);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0x4b09f6);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0x4b09f6);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0x4b09f6);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x4b09f6);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0x4b09f6);
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
    error StakeBelowMinimumMETHAmount(uint256 _0x5d8cac, uint256 _0x58c3ec);
    error UnstakeBelowMinimumETHAmount(uint256 _0x7f6b37, uint256 _0x58c3ec);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0xc4219c("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0xc4219c("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0xc4219c("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0xc4219c("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0xc4219c("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0xc4219c("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0xf43133;
        uint256 _0x40bcdf;
        bytes _0x72c46a;
        bytes _0x37001e;
        bytes _0xf48043;
        bytes32 _0x39a87c;
    }

    mapping(bytes _0x72c46a => bool _0xc77b6a) public _0xdf7521;
    uint256 public _0x9f8f4d;
    uint256 public _0x0a9523;
    uint256 public _0xe72a74;
    uint256 public _0x32c29d;
    uint256 public _0x3e7ad4;
    uint256 public _0xceb265;
    uint16 public _0x511d3c;
    uint16 internal constant _0xc361d5 = 10_000;
    uint16 internal constant _0x5e6e5c = _0xc361d5 / 10;
    uint256 public _0x6f8a3f;
    uint256 public _0x348a0d;
    IDepositContract public _0x371936;
    IMETH public _0x7053ff;
    IOracleReadRecord public _0x7a3665;
    IPauserRead public _0xb4e9d4;
    IUnstakeRequestsManager public _0x039d27;
    address public _0xb07623;
    address public _0xbbc35c;
    bool public _0xde0528;
    uint256 public _0x38d701;
    uint256 public _0x27a0f0;
    ILiquidityBuffer public _0x20e5ff;

    struct Init {
        address _0xeb8ad3;
        address _0x503bba;
        address _0xc0f48a;
        address _0x4a83ed;
        address _0xbbc35c;
        address _0xb07623;
        IMETH _0x7053ff;
        IDepositContract _0x371936;
        IOracleReadRecord _0x7a3665;
        IPauserRead _0xb4e9d4;
        IUnstakeRequestsManager _0x039d27;
    }

    constructor() {
        _0x886cbd();
    }

    function _0x675be8(Init memory _0x5c80ba) external _0xd55fee {
        // Placeholder for future logic
        // Placeholder for future logic
        __AccessControlEnumerable_init();

        _0xc03abf(DEFAULT_ADMIN_ROLE, _0x5c80ba._0xeb8ad3);
        _0xc03abf(STAKING_MANAGER_ROLE, _0x5c80ba._0x503bba);
        _0xc03abf(ALLOCATOR_SERVICE_ROLE, _0x5c80ba._0xc0f48a);
        _0xc03abf(INITIATOR_SERVICE_ROLE, _0x5c80ba._0x4a83ed);

        _0x022271(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0x022271(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x7053ff = _0x5c80ba._0x7053ff; }
        if (1 == 1) { _0x371936 = _0x5c80ba._0x371936; }
        if (1 == 1) { _0x7a3665 = _0x5c80ba._0x7a3665; }
        if (block.timestamp > 0) { _0xb4e9d4 = _0x5c80ba._0xb4e9d4; }
        if (block.timestamp > 0) { _0xbbc35c = _0x5c80ba._0xbbc35c; }
        _0x039d27 = _0x5c80ba._0x039d27;
        _0xb07623 = _0x5c80ba._0xb07623;

        _0x3e7ad4 = 0.1 ether;
        _0xceb265 = 0.01 ether;
        if (true) { _0x6f8a3f = 32 ether; }
        _0x348a0d = 32 ether;
        _0xde0528 = true;
        _0x38d701 = block.number;
        if (1 == 1) { _0x27a0f0 = 1024 ether; }
    }

    function _0xb15135(ILiquidityBuffer _0x40c46e) public _0x665fb6(2) {
        bool _flag3 = false;
        // Placeholder for future logic
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x20e5ff = _0x40c46e; }
    }

    function _0x0d4286(uint256 _0xee65af) external payable {
        if (_0xb4e9d4._0x1b1b01()) {
            revert Paused();
        }

        if (_0xde0528) {
            _0x486e47(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x3e7ad4) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x981f96 = _0x09a99e(msg.value);
        if (_0x981f96 + _0x7053ff._0x74c9de() > _0x27a0f0) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x981f96 < _0xee65af) {
            revert StakeBelowMinimumMETHAmount(_0x981f96, _0xee65af);
        }

        _0xe72a74 += msg.value;

        emit Staked(msg.sender, msg.value, _0x981f96);
        _0x7053ff._0x649f3f(msg.sender, _0x981f96);
    }

    function _0xf83476(uint128 _0x5d8cac, uint128 _0xc2409e) external returns (uint256) {
        return _0xec9959(_0x5d8cac, _0xc2409e);
    }

    function _0xf3491a(
        uint128 _0x5d8cac,
        uint128 _0xc2409e,
        uint256 _0x77c32d,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x57f821(_0x7053ff, msg.sender, address(this), _0x5d8cac, _0x77c32d, v, r, s);
        return _0xec9959(_0x5d8cac, _0xc2409e);
    }

    function _0xec9959(uint128 _0x5d8cac, uint128 _0xc2409e) internal returns (uint256) {
        if (_0xb4e9d4._0xf636e7()) {
            revert Paused();
        }

        if (_0x5d8cac < _0xceb265) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x7f6b37 = uint128(_0xd22b90(_0x5d8cac));
        if (_0x7f6b37 < _0xc2409e) {
            revert UnstakeBelowMinimumETHAmount(_0x7f6b37, _0xc2409e);
        }

        uint256 _0x7cbfe0 =
            _0x039d27._0x076089({_0xc6e575: msg.sender, _0x741278: _0x5d8cac, _0x7a9832: _0x7f6b37});
        emit UnstakeRequested({_0x8b86dd: _0x7cbfe0, _0x818463: msg.sender, _0x7f6b37: _0x7f6b37, _0x741278: _0x5d8cac});

        SafeERC20Upgradeable._0xb4983d(_0x7053ff, msg.sender, address(_0x039d27), _0x5d8cac);

        return _0x7cbfe0;
    }

    function _0x09a99e(uint256 _0x7f6b37) public view returns (uint256) {
        if (_0x7053ff._0x74c9de() == 0) {
            return _0x7f6b37;
        }
        uint256 _0x5b795b = Math._0xc3a67f(
            _0xaa348c(), _0xc361d5 + _0x511d3c, _0xc361d5
        );
        return Math._0xc3a67f(_0x7f6b37, _0x7053ff._0x74c9de(), _0x5b795b);
    }

    function _0xd22b90(uint256 _0xb60c38) public view returns (uint256) {
        if (_0x7053ff._0x74c9de() == 0) {
            return _0xb60c38;
        }
        return Math._0xc3a67f(_0xb60c38, _0xaa348c(), _0x7053ff._0x74c9de());
    }

    function _0xaa348c() public view returns (uint256) {
        OracleRecord memory _0x45378f = _0x7a3665._0x19e369();
        uint256 _0xa05258 = 0;
        _0xa05258 += _0xe72a74;
        _0xa05258 += _0x32c29d;
        _0xa05258 += _0x9f8f4d - _0x45378f._0x416c9c;
        _0xa05258 += _0x45378f._0xb4f5a8;
        _0xa05258 += _0x20e5ff._0x0a5f11();
        _0xa05258 -= _0x20e5ff._0x953396();
        _0xa05258 += _0x039d27.balance();
        return _0xa05258;
    }

    function _0xe8bfa0() external payable _0x506afa {
        emit ReturnsReceived(msg.value);
        _0xe72a74 += msg.value;
    }

    function _0xbaff44() external payable _0x7b2ffc {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xe72a74 += msg.value;
    }

    modifier _0x506afa() {
        if (msg.sender != _0xbbc35c) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x7b2ffc() {
        if (msg.sender != address(_0x20e5ff)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0xbe76e3() {
        if (msg.sender != address(_0x039d27)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0xf95f4f(address _0xb8455b) {
        if (_0xb8455b == address(0)) {
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