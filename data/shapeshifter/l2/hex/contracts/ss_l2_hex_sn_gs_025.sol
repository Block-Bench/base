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
    event Staked(address indexed _0xfda57a, uint256 _0x99177a, uint256 _0xad66e4);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0xb4c52c, address indexed _0xfda57a, uint256 _0x99177a, uint256 _0x40a542);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0xb4c52c, address indexed _0xfda57a);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0xb4c52c, uint256 indexed _0xeb62b1, bytes _0x0dcc5d, uint256 _0x56a255);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0x33859a);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0x33859a);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0x33859a);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x33859a);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0x33859a);
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
    error StakeBelowMinimumMETHAmount(uint256 _0x48905d, uint256 _0xc27608);
    error UnstakeBelowMinimumETHAmount(uint256 _0x99177a, uint256 _0xc27608);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x78d684("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x78d684("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x78d684("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x78d684("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x78d684("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x78d684("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0xeb62b1;
        uint256 _0x008961;
        bytes _0x0dcc5d;
        bytes _0x361db2;
        bytes _0xc4d237;
        bytes32 _0xd64848;
    }

    mapping(bytes _0x0dcc5d => bool _0x335315) public _0x645170;
    uint256 public _0x3587a4;
    uint256 public _0x1b3a50;
    uint256 public _0xb6edc7;
    uint256 public _0x500f1e;
    uint256 public _0xb01a4d;
    uint256 public _0xa04e49;
    uint16 public _0x44309d;
    uint16 internal constant _0x539f8a = 10_000;
    uint16 internal constant _0x2b17ee = _0x539f8a / 10;
    uint256 public _0x670e5f;
    uint256 public _0xfc5921;
    IDepositContract public _0x67a874;
    IMETH public _0x4e1a76;
    IOracleReadRecord public _0x80b1ac;
    IPauserRead public _0x66761a;
    IUnstakeRequestsManager public _0xa59f3b;
    address public _0xe74ae5;
    address public _0x71a7f4;
    bool public _0x7ab509;
    uint256 public _0x47af74;
    uint256 public _0xa43cb0;
    ILiquidityBuffer public _0x0bebee;

    struct Init {
        address _0x1f5117;
        address _0x9c2bff;
        address _0x21b2c8;
        address _0x62f45d;
        address _0x71a7f4;
        address _0xe74ae5;
        IMETH _0x4e1a76;
        IDepositContract _0x67a874;
        IOracleReadRecord _0x80b1ac;
        IPauserRead _0x66761a;
        IUnstakeRequestsManager _0xa59f3b;
    }

    constructor() {
        _0x44e29b();
    }

    function _0x2a8b57(Init memory _0x88adbd) external _0x32643e {
        __AccessControlEnumerable_init();

        _0x104ec5(DEFAULT_ADMIN_ROLE, _0x88adbd._0x1f5117);
        _0x104ec5(STAKING_MANAGER_ROLE, _0x88adbd._0x9c2bff);
        _0x104ec5(ALLOCATOR_SERVICE_ROLE, _0x88adbd._0x21b2c8);
        _0x104ec5(INITIATOR_SERVICE_ROLE, _0x88adbd._0x62f45d);

        _0x94c038(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0x94c038(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0x4e1a76 = _0x88adbd._0x4e1a76;
        _0x67a874 = _0x88adbd._0x67a874;
        _0x80b1ac = _0x88adbd._0x80b1ac;
        _0x66761a = _0x88adbd._0x66761a;
        _0x71a7f4 = _0x88adbd._0x71a7f4;
        _0xa59f3b = _0x88adbd._0xa59f3b;
        _0xe74ae5 = _0x88adbd._0xe74ae5;

        _0xb01a4d = 0.1 ether;
        _0xa04e49 = 0.01 ether;
        _0x670e5f = 32 ether;
        _0xfc5921 = 32 ether;
        _0x7ab509 = true;
        _0x47af74 = block.number;
        _0xa43cb0 = 1024 ether;
    }

    function _0xf887ea(ILiquidityBuffer _0x24db19) public _0x0e4149(2) {
        _0x0bebee = _0x24db19;
    }

    function _0xab2e97(uint256 _0x280101) external payable {
        if (_0x66761a._0x912c28()) {
            revert Paused();
        }

        if (_0x7ab509) {
            _0x5c6a3f(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0xb01a4d) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x20e057 = _0xbfe1c8(msg.value);
        if (_0x20e057 + _0x4e1a76._0x09d497() > _0xa43cb0) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x20e057 < _0x280101) {
            revert StakeBelowMinimumMETHAmount(_0x20e057, _0x280101);
        }

        _0xb6edc7 += msg.value;

        emit Staked(msg.sender, msg.value, _0x20e057);
        _0x4e1a76._0xb5fbb7(msg.sender, _0x20e057);
    }

    function _0x393d53(uint128 _0x48905d, uint128 _0x7c3308) external returns (uint256) {
        return _0xb67bd4(_0x48905d, _0x7c3308);
    }

    function _0x85ec2e(
        uint128 _0x48905d,
        uint128 _0x7c3308,
        uint256 _0xbc6949,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0xf41cd0(_0x4e1a76, msg.sender, address(this), _0x48905d, _0xbc6949, v, r, s);
        return _0xb67bd4(_0x48905d, _0x7c3308);
    }

    function _0xb67bd4(uint128 _0x48905d, uint128 _0x7c3308) internal returns (uint256) {
        if (_0x66761a._0x207f1d()) {
            revert Paused();
        }

        if (_0x48905d < _0xa04e49) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x99177a = uint128(_0xd4df03(_0x48905d));
        if (_0x99177a < _0x7c3308) {
            revert UnstakeBelowMinimumETHAmount(_0x99177a, _0x7c3308);
        }

        uint256 _0x8b3c00 =
            _0xa59f3b._0x0060c4({_0xae958e: msg.sender, _0x40a542: _0x48905d, _0x83e568: _0x99177a});
        emit UnstakeRequested({_0xb4c52c: _0x8b3c00, _0xfda57a: msg.sender, _0x99177a: _0x99177a, _0x40a542: _0x48905d});

        SafeERC20Upgradeable._0xf2cf9a(_0x4e1a76, msg.sender, address(_0xa59f3b), _0x48905d);

        return _0x8b3c00;
    }

    function _0xbfe1c8(uint256 _0x99177a) public view returns (uint256) {
        if (_0x4e1a76._0x09d497() == 0) {
            return _0x99177a;
        }
        uint256 _0x0b981c = Math._0x2a6836(
            _0x15b8ff(), _0x539f8a + _0x44309d, _0x539f8a
        );
        return Math._0x2a6836(_0x99177a, _0x4e1a76._0x09d497(), _0x0b981c);
    }

    function _0xd4df03(uint256 _0xad66e4) public view returns (uint256) {
        if (_0x4e1a76._0x09d497() == 0) {
            return _0xad66e4;
        }
        return Math._0x2a6836(_0xad66e4, _0x15b8ff(), _0x4e1a76._0x09d497());
    }

    function _0x15b8ff() public view returns (uint256) {
        OracleRecord memory _0xf5fff7 = _0x80b1ac._0x075067();
        uint256 _0xd87495 = 0;
        _0xd87495 += _0xb6edc7;
        _0xd87495 += _0x500f1e;
        _0xd87495 += _0x3587a4 - _0xf5fff7._0xf6cb87;
        _0xd87495 += _0xf5fff7._0x66f749;
        _0xd87495 += _0x0bebee._0x288a2b();
        _0xd87495 -= _0x0bebee._0x7342e8();
        _0xd87495 += _0xa59f3b.balance();
        return _0xd87495;
    }

    function _0x3a9bdd() external payable _0x507d3c {
        emit ReturnsReceived(msg.value);
        _0xb6edc7 += msg.value;
    }

    function _0xc67f40() external payable _0x83daf2 {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xb6edc7 += msg.value;
    }

    modifier _0x507d3c() {
        if (msg.sender != _0x71a7f4) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x83daf2() {
        if (msg.sender != address(_0x0bebee)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x5480b5() {
        if (msg.sender != address(_0xa59f3b)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x149d27(address _0x8ba9db) {
        if (_0x8ba9db == address(0)) {
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