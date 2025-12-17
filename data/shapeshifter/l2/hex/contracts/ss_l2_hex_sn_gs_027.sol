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
    event Staked(address indexed _0xb34323, uint256 _0x3f9d54, uint256 _0xe7ed00);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0xce7b0c, address indexed _0xb34323, uint256 _0x3f9d54, uint256 _0xcb2a2a);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0xce7b0c, address indexed _0xb34323);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0xce7b0c, uint256 indexed _0xc31be8, bytes _0x28e2b0, uint256 _0x2359f6);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0xb687a1);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0xb687a1);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0xb687a1);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0xb687a1);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0xb687a1);
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
    error StakeBelowMinimumMETHAmount(uint256 _0xedce5e, uint256 _0xe3c0e2);
    error UnstakeBelowMinimumETHAmount(uint256 _0x3f9d54, uint256 _0xe3c0e2);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x0525ea("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x0525ea("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x0525ea("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x0525ea("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x0525ea("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x0525ea("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0xc31be8;
        uint256 _0x7df69f;
        bytes _0x28e2b0;
        bytes _0x21b8e8;
        bytes _0x530436;
        bytes32 _0x11cbcb;
    }

    mapping(bytes _0x28e2b0 => bool _0x2ac226) public _0x4959e4;
    uint256 public _0x7e797b;
    uint256 public _0x1f3129;
    uint256 public _0xfca343;
    uint256 public _0x77454d;
    uint256 public _0x5094ed;
    uint256 public _0x054b05;
    uint16 public _0xd1b01f;
    uint16 internal constant _0xad3294 = 10_000;
    uint16 internal constant _0x25fc27 = _0xad3294 / 10;
    uint256 public _0x5cad8e;
    uint256 public _0x4ab7b0;
    IDepositContract public _0x064941;
    IMETH public _0x307d8a;
    IOracleReadRecord public _0xc01a34;
    IPauserRead public _0x68eda1;
    IUnstakeRequestsManager public _0x9451b9;
    address public _0xe83969;
    address public _0x6b80eb;
    bool public _0x462014;
    uint256 public _0x11f274;
    uint256 public _0x55ffb7;
    ILiquidityBuffer public _0xf6ec6b;

    struct Init {
        address _0x96fc16;
        address _0x2bad16;
        address _0x4ebbac;
        address _0x4c8e53;
        address _0x6b80eb;
        address _0xe83969;
        IMETH _0x307d8a;
        IDepositContract _0x064941;
        IOracleReadRecord _0xc01a34;
        IPauserRead _0x68eda1;
        IUnstakeRequestsManager _0x9451b9;
    }

    constructor() {
        _0x03b88d();
    }

    function _0xa9e5e7(Init memory _0x665ff9) external _0x73a9fd {
        __AccessControlEnumerable_init();

        _0xb23122(DEFAULT_ADMIN_ROLE, _0x665ff9._0x96fc16);
        _0xb23122(STAKING_MANAGER_ROLE, _0x665ff9._0x2bad16);
        _0xb23122(ALLOCATOR_SERVICE_ROLE, _0x665ff9._0x4ebbac);
        _0xb23122(INITIATOR_SERVICE_ROLE, _0x665ff9._0x4c8e53);

        _0x03165b(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0x03165b(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0x307d8a = _0x665ff9._0x307d8a;
        _0x064941 = _0x665ff9._0x064941;
        _0xc01a34 = _0x665ff9._0xc01a34;
        _0x68eda1 = _0x665ff9._0x68eda1;
        _0x6b80eb = _0x665ff9._0x6b80eb;
        _0x9451b9 = _0x665ff9._0x9451b9;
        _0xe83969 = _0x665ff9._0xe83969;

        _0x5094ed = 0.1 ether;
        _0x054b05 = 0.01 ether;
        _0x5cad8e = 32 ether;
        _0x4ab7b0 = 32 ether;
        _0x462014 = true;
        _0x11f274 = block.number;
        _0x55ffb7 = 1024 ether;
    }

    function _0x415a8a(ILiquidityBuffer _0x0abcc5) public _0x308c73(2) {
        _0xf6ec6b = _0x0abcc5;
    }

    function _0x1f1d93(uint256 _0x6eb0aa) external payable {
        if (_0x68eda1._0x5edcec()) {
            revert Paused();
        }

        if (_0x462014) {
            _0xc2a0fd(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x5094ed) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x7f91eb = _0x58d7dd(msg.value);
        if (_0x7f91eb + _0x307d8a._0xff89fb() > _0x55ffb7) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x7f91eb < _0x6eb0aa) {
            revert StakeBelowMinimumMETHAmount(_0x7f91eb, _0x6eb0aa);
        }

        _0xfca343 += msg.value;

        emit Staked(msg.sender, msg.value, _0x7f91eb);
        _0x307d8a._0x89b3ff(msg.sender, _0x7f91eb);
    }

    function _0x137479(uint128 _0xedce5e, uint128 _0x546011) external returns (uint256) {
        return _0xe61a23(_0xedce5e, _0x546011);
    }

    function _0xc8be2f(
        uint128 _0xedce5e,
        uint128 _0x546011,
        uint256 _0xcaea3e,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x65c6f8(_0x307d8a, msg.sender, address(this), _0xedce5e, _0xcaea3e, v, r, s);
        return _0xe61a23(_0xedce5e, _0x546011);
    }

    function _0xe61a23(uint128 _0xedce5e, uint128 _0x546011) internal returns (uint256) {
        if (_0x68eda1._0x226767()) {
            revert Paused();
        }

        if (_0xedce5e < _0x054b05) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x3f9d54 = uint128(_0x1d5b3c(_0xedce5e));
        if (_0x3f9d54 < _0x546011) {
            revert UnstakeBelowMinimumETHAmount(_0x3f9d54, _0x546011);
        }

        uint256 _0x555f5f =
            _0x9451b9._0x1ea531({_0xe152a1: msg.sender, _0xcb2a2a: _0xedce5e, _0x2c8217: _0x3f9d54});
        emit UnstakeRequested({_0xce7b0c: _0x555f5f, _0xb34323: msg.sender, _0x3f9d54: _0x3f9d54, _0xcb2a2a: _0xedce5e});

        SafeERC20Upgradeable._0x7f14ac(_0x307d8a, msg.sender, address(_0x9451b9), _0xedce5e);

        return _0x555f5f;
    }

    function _0x58d7dd(uint256 _0x3f9d54) public view returns (uint256) {
        if (_0x307d8a._0xff89fb() == 0) {
            return _0x3f9d54;
        }
        uint256 _0xd8a597 = Math._0xba1804(
            _0xb696e3(), _0xad3294 + _0xd1b01f, _0xad3294
        );
        return Math._0xba1804(_0x3f9d54, _0x307d8a._0xff89fb(), _0xd8a597);
    }

    function _0x1d5b3c(uint256 _0xe7ed00) public view returns (uint256) {
        if (_0x307d8a._0xff89fb() == 0) {
            return _0xe7ed00;
        }
        return Math._0xba1804(_0xe7ed00, _0xb696e3(), _0x307d8a._0xff89fb());
    }

    function _0xb696e3() public view returns (uint256) {
        OracleRecord memory _0x942a1a = _0xc01a34._0x9f88b7();
        uint256 _0xda088e = 0;
        _0xda088e += _0xfca343;
        _0xda088e += _0x77454d;
        _0xda088e += _0x7e797b - _0x942a1a._0x322069;
        _0xda088e += _0x942a1a._0xba3a97;
        _0xda088e += _0xf6ec6b._0x952361();
        _0xda088e -= _0xf6ec6b._0x4587d5();
        _0xda088e += _0x9451b9.balance();
        return _0xda088e;
    }

    function _0x11f931() external payable _0x081299 {
        emit ReturnsReceived(msg.value);
        _0xfca343 += msg.value;
    }

    function _0x7cb5f0() external payable _0x542716 {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xfca343 += msg.value;
    }

    modifier _0x081299() {
        if (msg.sender != _0x6b80eb) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x542716() {
        if (msg.sender != address(_0xf6ec6b)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x185ca2() {
        if (msg.sender != address(_0x9451b9)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0xef109a(address _0x8e58a2) {
        if (_0x8e58a2 == address(0)) {
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