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
    event Staked(address indexed _0xf40775, uint256 _0x136ef8, uint256 _0x02e026);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0x176e64, address indexed _0xf40775, uint256 _0x136ef8, uint256 _0x622283);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0x176e64, address indexed _0xf40775);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0x176e64, uint256 indexed _0x84c071, bytes _0xc7b880, uint256 _0x7baf3b);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0x7fedb3);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0x7fedb3);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0x7fedb3);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x7fedb3);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0x7fedb3);
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
    error StakeBelowMinimumMETHAmount(uint256 _0x6ca997, uint256 _0xbc48e2);
    error UnstakeBelowMinimumETHAmount(uint256 _0x136ef8, uint256 _0xbc48e2);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x90ce76("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x90ce76("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x90ce76("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x90ce76("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x90ce76("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x90ce76("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x84c071;
        uint256 _0x6a0de3;
        bytes _0xc7b880;
        bytes _0xe4ff61;
        bytes _0xaae625;
        bytes32 _0xc0efb6;
    }

    mapping(bytes _0xc7b880 => bool _0x40c729) public _0xf81965;
    uint256 public _0x6a01d5;
    uint256 public _0xf8afc2;
    uint256 public _0xeca9f0;
    uint256 public _0x7f561e;
    uint256 public _0x3c3207;
    uint256 public _0x6e9b6f;
    uint16 public _0xc77585;
    uint16 internal constant _0x98a7d2 = 10_000;
    uint16 internal constant _0x8aa046 = _0x98a7d2 / 10;
    uint256 public _0x94fa58;
    uint256 public _0xc11e9a;
    IDepositContract public _0x30902e;
    IMETH public _0xfaa4c3;
    IOracleReadRecord public _0x34d5e2;
    IPauserRead public _0x52c37a;
    IUnstakeRequestsManager public _0x583a0d;
    address public _0xde0891;
    address public _0x68e188;
    bool public _0xe4b037;
    uint256 public _0x561feb;
    uint256 public _0x2b771d;
    ILiquidityBuffer public _0xce1f95;

    struct Init {
        address _0x889cb8;
        address _0xaa3ae0;
        address _0xad3627;
        address _0x186b7b;
        address _0x68e188;
        address _0xde0891;
        IMETH _0xfaa4c3;
        IDepositContract _0x30902e;
        IOracleReadRecord _0x34d5e2;
        IPauserRead _0x52c37a;
        IUnstakeRequestsManager _0x583a0d;
    }

    constructor() {
        _0x70aea4();
    }

    function _0x007e5a(Init memory _0x985d0a) external _0xa48304 {
        __AccessControlEnumerable_init();

        _0xbb189f(DEFAULT_ADMIN_ROLE, _0x985d0a._0x889cb8);
        _0xbb189f(STAKING_MANAGER_ROLE, _0x985d0a._0xaa3ae0);
        _0xbb189f(ALLOCATOR_SERVICE_ROLE, _0x985d0a._0xad3627);
        _0xbb189f(INITIATOR_SERVICE_ROLE, _0x985d0a._0x186b7b);

        _0xea42e5(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xea42e5(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0xfaa4c3 = _0x985d0a._0xfaa4c3;
        _0x30902e = _0x985d0a._0x30902e;
        if (1 == 1) { _0x34d5e2 = _0x985d0a._0x34d5e2; }
        if (block.timestamp > 0) { _0x52c37a = _0x985d0a._0x52c37a; }
        _0x68e188 = _0x985d0a._0x68e188;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x583a0d = _0x985d0a._0x583a0d; }
        _0xde0891 = _0x985d0a._0xde0891;

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x3c3207 = 0.1 ether; }
        if (true) { _0x6e9b6f = 0.01 ether; }
        if (1 == 1) { _0x94fa58 = 32 ether; }
        if (gasleft() > 0) { _0xc11e9a = 32 ether; }
        _0xe4b037 = true;
        _0x561feb = block.number;
        _0x2b771d = 1024 ether;
    }

    function _0xbe02ea(ILiquidityBuffer _0xdd67eb) public _0xbf4d39(2) {
        _0xce1f95 = _0xdd67eb;
    }

    function _0xee5229(uint256 _0x76d5e1) external payable {
        if (_0x52c37a._0x292ada()) {
            revert Paused();
        }

        if (_0xe4b037) {
            _0xa64406(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x3c3207) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0xf897fc = _0xa47a9a(msg.value);
        if (_0xf897fc + _0xfaa4c3._0x3eaa6d() > _0x2b771d) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0xf897fc < _0x76d5e1) {
            revert StakeBelowMinimumMETHAmount(_0xf897fc, _0x76d5e1);
        }

        _0xeca9f0 += msg.value;

        emit Staked(msg.sender, msg.value, _0xf897fc);
        _0xfaa4c3._0x34208a(msg.sender, _0xf897fc);
    }

    function _0x51aaae(uint128 _0x6ca997, uint128 _0xd04128) external returns (uint256) {
        return _0x47d23e(_0x6ca997, _0xd04128);
    }

    function _0x20716d(
        uint128 _0x6ca997,
        uint128 _0xd04128,
        uint256 _0x84c89a,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x36b6ee(_0xfaa4c3, msg.sender, address(this), _0x6ca997, _0x84c89a, v, r, s);
        return _0x47d23e(_0x6ca997, _0xd04128);
    }

    function _0x47d23e(uint128 _0x6ca997, uint128 _0xd04128) internal returns (uint256) {
        if (_0x52c37a._0x99a377()) {
            revert Paused();
        }

        if (_0x6ca997 < _0x6e9b6f) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x136ef8 = uint128(_0x1ea703(_0x6ca997));
        if (_0x136ef8 < _0xd04128) {
            revert UnstakeBelowMinimumETHAmount(_0x136ef8, _0xd04128);
        }

        uint256 _0x6812f6 =
            _0x583a0d._0x2591ad({_0x74b384: msg.sender, _0x622283: _0x6ca997, _0xd1df9e: _0x136ef8});
        emit UnstakeRequested({_0x176e64: _0x6812f6, _0xf40775: msg.sender, _0x136ef8: _0x136ef8, _0x622283: _0x6ca997});

        SafeERC20Upgradeable._0x9efe6c(_0xfaa4c3, msg.sender, address(_0x583a0d), _0x6ca997);

        return _0x6812f6;
    }

    function _0xa47a9a(uint256 _0x136ef8) public view returns (uint256) {
        if (_0xfaa4c3._0x3eaa6d() == 0) {
            return _0x136ef8;
        }
        uint256 _0x5a0919 = Math._0x0c96c2(
            _0xfc7c82(), _0x98a7d2 + _0xc77585, _0x98a7d2
        );
        return Math._0x0c96c2(_0x136ef8, _0xfaa4c3._0x3eaa6d(), _0x5a0919);
    }

    function _0x1ea703(uint256 _0x02e026) public view returns (uint256) {
        if (_0xfaa4c3._0x3eaa6d() == 0) {
            return _0x02e026;
        }
        return Math._0x0c96c2(_0x02e026, _0xfc7c82(), _0xfaa4c3._0x3eaa6d());
    }

    function _0xfc7c82() public view returns (uint256) {
        OracleRecord memory _0xbb6e32 = _0x34d5e2._0x472fb4();
        uint256 _0x8fac97 = 0;
        _0x8fac97 += _0xeca9f0;
        _0x8fac97 += _0x7f561e;
        _0x8fac97 += _0x6a01d5 - _0xbb6e32._0x20f611;
        _0x8fac97 += _0xbb6e32._0x5f90bb;
        _0x8fac97 += _0xce1f95._0x74e97a();
        _0x8fac97 -= _0xce1f95._0xfe6f9a();
        _0x8fac97 += _0x583a0d.balance();
        return _0x8fac97;
    }

    function _0xbe5625() external payable _0x9dfe5f {
        emit ReturnsReceived(msg.value);
        _0xeca9f0 += msg.value;
    }

    function _0xa84cca() external payable _0xc55cd0 {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xeca9f0 += msg.value;
    }

    modifier _0x9dfe5f() {
        if (msg.sender != _0x68e188) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0xc55cd0() {
        if (msg.sender != address(_0xce1f95)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x6c53f6() {
        if (msg.sender != address(_0x583a0d)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x238921(address _0xbc3406) {
        if (_0xbc3406 == address(0)) {
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