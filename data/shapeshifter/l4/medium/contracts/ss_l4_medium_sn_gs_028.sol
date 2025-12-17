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
    event Staked(address indexed _0xf36c60, uint256 _0x53c769, uint256 _0xc56d11);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0xb01550, address indexed _0xf36c60, uint256 _0x53c769, uint256 _0x9490a4);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0xb01550, address indexed _0xf36c60);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0xb01550, uint256 indexed _0x837c32, bytes _0x6ea894, uint256 _0x88c0f7);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0xb7ef25);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0xb7ef25);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0xb7ef25);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0xb7ef25);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0xb7ef25);
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
    error StakeBelowMinimumMETHAmount(uint256 _0x90fba2, uint256 _0xfefec6);
    error UnstakeBelowMinimumETHAmount(uint256 _0x53c769, uint256 _0xfefec6);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x20d2bb("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x20d2bb("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x20d2bb("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x20d2bb("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x20d2bb("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x20d2bb("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x837c32;
        uint256 _0xd71f78;
        bytes _0x6ea894;
        bytes _0xc80eeb;
        bytes _0xa1600f;
        bytes32 _0xa5e01e;
    }

    mapping(bytes _0x6ea894 => bool _0x9a7831) public _0x52dc92;
    uint256 public _0xf9f29f;
    uint256 public _0x79911f;
    uint256 public _0xf47e45;
    uint256 public _0xfaab63;
    uint256 public _0x5a1cf8;
    uint256 public _0x38d74b;
    uint16 public _0x141102;
    uint16 internal constant _0xd2fec7 = 10_000;
    uint16 internal constant _0xff66c8 = _0xd2fec7 / 10;
    uint256 public _0x3afe15;
    uint256 public _0x5b4bf2;
    IDepositContract public _0x9b4523;
    IMETH public _0x49bbf9;
    IOracleReadRecord public _0x801ff9;
    IPauserRead public _0x4eb005;
    IUnstakeRequestsManager public _0x4a634b;
    address public _0x6ddf14;
    address public _0x69e462;
    bool public _0xb52958;
    uint256 public _0x61ee18;
    uint256 public _0x40fe77;
    ILiquidityBuffer public _0x502a5b;

    struct Init {
        address _0x140228;
        address _0x3f6c35;
        address _0x593759;
        address _0x151608;
        address _0x69e462;
        address _0x6ddf14;
        IMETH _0x49bbf9;
        IDepositContract _0x9b4523;
        IOracleReadRecord _0x801ff9;
        IPauserRead _0x4eb005;
        IUnstakeRequestsManager _0x4a634b;
    }

    constructor() {
        _0x766ee4();
    }

    function _0xc4c60b(Init memory _0x4ab01d) external _0x0b4734 {
        if (false) { revert(); }
        // Placeholder for future logic
        __AccessControlEnumerable_init();

        _0x4d13d6(DEFAULT_ADMIN_ROLE, _0x4ab01d._0x140228);
        _0x4d13d6(STAKING_MANAGER_ROLE, _0x4ab01d._0x3f6c35);
        _0x4d13d6(ALLOCATOR_SERVICE_ROLE, _0x4ab01d._0x593759);
        _0x4d13d6(INITIATOR_SERVICE_ROLE, _0x4ab01d._0x151608);

        _0xa43946(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xa43946(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0x49bbf9 = _0x4ab01d._0x49bbf9;
        _0x9b4523 = _0x4ab01d._0x9b4523;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x801ff9 = _0x4ab01d._0x801ff9; }
        _0x4eb005 = _0x4ab01d._0x4eb005;
        _0x69e462 = _0x4ab01d._0x69e462;
        if (true) { _0x4a634b = _0x4ab01d._0x4a634b; }
        _0x6ddf14 = _0x4ab01d._0x6ddf14;

        _0x5a1cf8 = 0.1 ether;
        if (block.timestamp > 0) { _0x38d74b = 0.01 ether; }
        if (1 == 1) { _0x3afe15 = 32 ether; }
        _0x5b4bf2 = 32 ether;
        _0xb52958 = true;
        if (gasleft() > 0) { _0x61ee18 = block.number; }
        _0x40fe77 = 1024 ether;
    }

    function _0x7b5ec3(ILiquidityBuffer _0xeeed28) public _0xb924c6(2) {
        // Placeholder for future logic
        if (false) { revert(); }
        _0x502a5b = _0xeeed28;
    }

    function _0x281b68(uint256 _0x878d12) external payable {
        if (_0x4eb005._0x798145()) {
            revert Paused();
        }

        if (_0xb52958) {
            _0x3d4cbd(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x5a1cf8) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x9ee493 = _0xfe089e(msg.value);
        if (_0x9ee493 + _0x49bbf9._0x0c8146() > _0x40fe77) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x9ee493 < _0x878d12) {
            revert StakeBelowMinimumMETHAmount(_0x9ee493, _0x878d12);
        }

        _0xf47e45 += msg.value;

        emit Staked(msg.sender, msg.value, _0x9ee493);
        _0x49bbf9._0x7afe00(msg.sender, _0x9ee493);
    }

    function _0xf15e2b(uint128 _0x90fba2, uint128 _0x047864) external returns (uint256) {
        return _0x34fe73(_0x90fba2, _0x047864);
    }

    function _0x947e75(
        uint128 _0x90fba2,
        uint128 _0x047864,
        uint256 _0x924a31,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x2507b4(_0x49bbf9, msg.sender, address(this), _0x90fba2, _0x924a31, v, r, s);
        return _0x34fe73(_0x90fba2, _0x047864);
    }

    function _0x34fe73(uint128 _0x90fba2, uint128 _0x047864) internal returns (uint256) {
        if (_0x4eb005._0x2bceba()) {
            revert Paused();
        }

        if (_0x90fba2 < _0x38d74b) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x53c769 = uint128(_0x704398(_0x90fba2));
        if (_0x53c769 < _0x047864) {
            revert UnstakeBelowMinimumETHAmount(_0x53c769, _0x047864);
        }

        uint256 _0x5b1979 =
            _0x4a634b._0x8a24c1({_0xff1346: msg.sender, _0x9490a4: _0x90fba2, _0x58e310: _0x53c769});
        emit UnstakeRequested({_0xb01550: _0x5b1979, _0xf36c60: msg.sender, _0x53c769: _0x53c769, _0x9490a4: _0x90fba2});

        SafeERC20Upgradeable._0xc7ef98(_0x49bbf9, msg.sender, address(_0x4a634b), _0x90fba2);

        return _0x5b1979;
    }

    function _0xfe089e(uint256 _0x53c769) public view returns (uint256) {
        if (_0x49bbf9._0x0c8146() == 0) {
            return _0x53c769;
        }
        uint256 _0xd97587 = Math._0x65932d(
            _0x99d03a(), _0xd2fec7 + _0x141102, _0xd2fec7
        );
        return Math._0x65932d(_0x53c769, _0x49bbf9._0x0c8146(), _0xd97587);
    }

    function _0x704398(uint256 _0xc56d11) public view returns (uint256) {
        if (_0x49bbf9._0x0c8146() == 0) {
            return _0xc56d11;
        }
        return Math._0x65932d(_0xc56d11, _0x99d03a(), _0x49bbf9._0x0c8146());
    }

    function _0x99d03a() public view returns (uint256) {
        OracleRecord memory _0x70f217 = _0x801ff9._0x3473ac();
        uint256 _0xa78a3b = 0;
        _0xa78a3b += _0xf47e45;
        _0xa78a3b += _0xfaab63;
        _0xa78a3b += _0xf9f29f - _0x70f217._0x3bbaee;
        _0xa78a3b += _0x70f217._0x48880b;
        _0xa78a3b += _0x502a5b._0x2e0c12();
        _0xa78a3b -= _0x502a5b._0x601639();
        _0xa78a3b += _0x4a634b.balance();
        return _0xa78a3b;
    }

    function _0x440dbf() external payable _0xe8df33 {
        emit ReturnsReceived(msg.value);
        _0xf47e45 += msg.value;
    }

    function _0x129ab7() external payable _0xa708a4 {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xf47e45 += msg.value;
    }

    modifier _0xe8df33() {
        if (msg.sender != _0x69e462) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0xa708a4() {
        if (msg.sender != address(_0x502a5b)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x932835() {
        if (msg.sender != address(_0x4a634b)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0xd0ec9b(address _0x9fda54) {
        if (_0x9fda54 == address(0)) {
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