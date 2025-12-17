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
    event Staked(address indexed _0xd01e02, uint256 _0x7c9ba5, uint256 _0x0248ba);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0x036721, address indexed _0xd01e02, uint256 _0x7c9ba5, uint256 _0xdacc5e);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0x036721, address indexed _0xd01e02);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0x036721, uint256 indexed _0x79cb83, bytes _0x8da423, uint256 _0x89395e);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0x079bdd);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0x079bdd);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0x079bdd);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x079bdd);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0x079bdd);
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
    error StakeBelowMinimumMETHAmount(uint256 _0xc7d397, uint256 _0x86b195);
    error UnstakeBelowMinimumETHAmount(uint256 _0x7c9ba5, uint256 _0x86b195);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0xee65fc("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0xee65fc("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0xee65fc("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0xee65fc("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0xee65fc("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0xee65fc("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x79cb83;
        uint256 _0x7f090f;
        bytes _0x8da423;
        bytes _0x9ad676;
        bytes _0x2ad157;
        bytes32 _0xe45518;
    }

    mapping(bytes _0x8da423 => bool _0x910d8b) public _0x118e23;
    uint256 public _0xd8d9c7;
    uint256 public _0xc52a5f;
    uint256 public _0x372bf0;
    uint256 public _0x1fb505;
    uint256 public _0xfee16f;
    uint256 public _0x663da6;
    uint16 public _0x95ed0c;
    uint16 internal constant _0x5531e7 = 10_000;
    uint16 internal constant _0x379585 = _0x5531e7 / 10;
    uint256 public _0x9ac968;
    uint256 public _0xa657c3;
    IDepositContract public _0xe3c00e;
    IMETH public _0x0c6a2b;
    IOracleReadRecord public _0xb35f0e;
    IPauserRead public _0x848af2;
    IUnstakeRequestsManager public _0xdb0051;
    address public _0x40cd20;
    address public _0x7e02d3;
    bool public _0x60e2b4;
    uint256 public _0xb7b26e;
    uint256 public _0x79b92f;
    ILiquidityBuffer public _0xfdeb18;

    struct Init {
        address _0x465828;
        address _0x2bdccd;
        address _0xe3b8c2;
        address _0x4d61d8;
        address _0x7e02d3;
        address _0x40cd20;
        IMETH _0x0c6a2b;
        IDepositContract _0xe3c00e;
        IOracleReadRecord _0xb35f0e;
        IPauserRead _0x848af2;
        IUnstakeRequestsManager _0xdb0051;
    }

    constructor() {
        _0xf0935e();
    }

    function _0xe78826(Init memory _0x7182b3) external _0x1c9467 {
        __AccessControlEnumerable_init();

        _0x32e155(DEFAULT_ADMIN_ROLE, _0x7182b3._0x465828);
        _0x32e155(STAKING_MANAGER_ROLE, _0x7182b3._0x2bdccd);
        _0x32e155(ALLOCATOR_SERVICE_ROLE, _0x7182b3._0xe3b8c2);
        _0x32e155(INITIATOR_SERVICE_ROLE, _0x7182b3._0x4d61d8);

        _0xcfc826(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xcfc826(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0x0c6a2b = _0x7182b3._0x0c6a2b;
        _0xe3c00e = _0x7182b3._0xe3c00e;
        _0xb35f0e = _0x7182b3._0xb35f0e;
        _0x848af2 = _0x7182b3._0x848af2;
        if (block.timestamp > 0) { _0x7e02d3 = _0x7182b3._0x7e02d3; }
        _0xdb0051 = _0x7182b3._0xdb0051;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x40cd20 = _0x7182b3._0x40cd20; }

        if (msg.sender != address(0) || msg.sender == address(0)) { _0xfee16f = 0.1 ether; }
        _0x663da6 = 0.01 ether;
        _0x9ac968 = 32 ether;
        _0xa657c3 = 32 ether;
        _0x60e2b4 = true;
        _0xb7b26e = block.number;
        _0x79b92f = 1024 ether;
    }

    function _0xb9fb24(ILiquidityBuffer _0xbc2f44) public _0xad803b(2) {
        _0xfdeb18 = _0xbc2f44;
    }

    function _0x2b94ca(uint256 _0x0c3638) external payable {
        if (_0x848af2._0xbdacda()) {
            revert Paused();
        }

        if (_0x60e2b4) {
            _0xe62d92(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0xfee16f) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x4c1b48 = _0x157d65(msg.value);
        if (_0x4c1b48 + _0x0c6a2b._0xbedbf2() > _0x79b92f) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x4c1b48 < _0x0c3638) {
            revert StakeBelowMinimumMETHAmount(_0x4c1b48, _0x0c3638);
        }

        _0x372bf0 += msg.value;

        emit Staked(msg.sender, msg.value, _0x4c1b48);
        _0x0c6a2b._0xd148d3(msg.sender, _0x4c1b48);
    }

    function _0x762a3d(uint128 _0xc7d397, uint128 _0x47efdd) external returns (uint256) {
        return _0x190ae7(_0xc7d397, _0x47efdd);
    }

    function _0x866fcd(
        uint128 _0xc7d397,
        uint128 _0x47efdd,
        uint256 _0x21ad8e,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0xb13d72(_0x0c6a2b, msg.sender, address(this), _0xc7d397, _0x21ad8e, v, r, s);
        return _0x190ae7(_0xc7d397, _0x47efdd);
    }

    function _0x190ae7(uint128 _0xc7d397, uint128 _0x47efdd) internal returns (uint256) {
        if (_0x848af2._0x1990a4()) {
            revert Paused();
        }

        if (_0xc7d397 < _0x663da6) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x7c9ba5 = uint128(_0x0721a9(_0xc7d397));
        if (_0x7c9ba5 < _0x47efdd) {
            revert UnstakeBelowMinimumETHAmount(_0x7c9ba5, _0x47efdd);
        }

        uint256 _0xdba3e7 =
            _0xdb0051._0x1763c9({_0xced563: msg.sender, _0xdacc5e: _0xc7d397, _0xbba33d: _0x7c9ba5});
        emit UnstakeRequested({_0x036721: _0xdba3e7, _0xd01e02: msg.sender, _0x7c9ba5: _0x7c9ba5, _0xdacc5e: _0xc7d397});

        SafeERC20Upgradeable._0x3bd27b(_0x0c6a2b, msg.sender, address(_0xdb0051), _0xc7d397);

        return _0xdba3e7;
    }

    function _0x157d65(uint256 _0x7c9ba5) public view returns (uint256) {
        if (_0x0c6a2b._0xbedbf2() == 0) {
            return _0x7c9ba5;
        }
        uint256 _0x6a3c1d = Math._0x66fd58(
            _0xe73b1f(), _0x5531e7 + _0x95ed0c, _0x5531e7
        );
        return Math._0x66fd58(_0x7c9ba5, _0x0c6a2b._0xbedbf2(), _0x6a3c1d);
    }

    function _0x0721a9(uint256 _0x0248ba) public view returns (uint256) {
        if (_0x0c6a2b._0xbedbf2() == 0) {
            return _0x0248ba;
        }
        return Math._0x66fd58(_0x0248ba, _0xe73b1f(), _0x0c6a2b._0xbedbf2());
    }

    function _0xe73b1f() public view returns (uint256) {
        OracleRecord memory _0x413e46 = _0xb35f0e._0xd26300();
        uint256 _0x177d81 = 0;
        _0x177d81 += _0x372bf0;
        _0x177d81 += _0x1fb505;
        _0x177d81 += _0xd8d9c7 - _0x413e46._0x28aa05;
        _0x177d81 += _0x413e46._0xe44f82;
        _0x177d81 += _0xfdeb18._0xaa4425();
        _0x177d81 -= _0xfdeb18._0x472c0f();
        _0x177d81 += _0xdb0051.balance();
        return _0x177d81;
    }

    function _0x812b75() external payable _0xe679ca {
        emit ReturnsReceived(msg.value);
        _0x372bf0 += msg.value;
    }

    function _0xab481a() external payable _0x5ea0db {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0x372bf0 += msg.value;
    }

    modifier _0xe679ca() {
        if (msg.sender != _0x7e02d3) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x5ea0db() {
        if (msg.sender != address(_0xfdeb18)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0xb57c59() {
        if (msg.sender != address(_0xdb0051)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0xd4df1d(address _0x9cd317) {
        if (_0x9cd317 == address(0)) {
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