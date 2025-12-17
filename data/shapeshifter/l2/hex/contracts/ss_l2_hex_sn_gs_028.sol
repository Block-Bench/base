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
    event Staked(address indexed _0x839a24, uint256 _0xe9899d, uint256 _0x008b3e);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0xe62b08, address indexed _0x839a24, uint256 _0xe9899d, uint256 _0xa7799e);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0xe62b08, address indexed _0x839a24);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0xe62b08, uint256 indexed _0x0d486d, bytes _0x848600, uint256 _0xd127b0);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0x049fc9);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0x049fc9);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0x049fc9);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x049fc9);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0x049fc9);
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
    error StakeBelowMinimumMETHAmount(uint256 _0x0e5bbd, uint256 _0x9ae417);
    error UnstakeBelowMinimumETHAmount(uint256 _0xe9899d, uint256 _0x9ae417);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0xb6e251("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0xb6e251("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0xb6e251("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0xb6e251("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0xb6e251("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0xb6e251("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x0d486d;
        uint256 _0xc6d17a;
        bytes _0x848600;
        bytes _0x35e718;
        bytes _0x7473fe;
        bytes32 _0xc3f66e;
    }

    mapping(bytes _0x848600 => bool _0xd0563e) public _0xea92c9;
    uint256 public _0x757e81;
    uint256 public _0x4ef952;
    uint256 public _0x81bfef;
    uint256 public _0xeeff52;
    uint256 public _0xa05967;
    uint256 public _0xdde84c;
    uint16 public _0x40b219;
    uint16 internal constant _0x59a9ff = 10_000;
    uint16 internal constant _0xd1b9e3 = _0x59a9ff / 10;
    uint256 public _0x4619a0;
    uint256 public _0x8b8f24;
    IDepositContract public _0x01ebdc;
    IMETH public _0xda536d;
    IOracleReadRecord public _0xee46e5;
    IPauserRead public _0xb58ab2;
    IUnstakeRequestsManager public _0x8c61b3;
    address public _0x341b0d;
    address public _0x71c2df;
    bool public _0xf8acfe;
    uint256 public _0xb70f7d;
    uint256 public _0x3d4207;
    ILiquidityBuffer public _0x810284;

    struct Init {
        address _0x64b136;
        address _0x6955e4;
        address _0x259ceb;
        address _0x6803c4;
        address _0x71c2df;
        address _0x341b0d;
        IMETH _0xda536d;
        IDepositContract _0x01ebdc;
        IOracleReadRecord _0xee46e5;
        IPauserRead _0xb58ab2;
        IUnstakeRequestsManager _0x8c61b3;
    }

    constructor() {
        _0x02afad();
    }

    function _0xd3045a(Init memory _0x6c6330) external _0x22d274 {
        __AccessControlEnumerable_init();

        _0xad12da(DEFAULT_ADMIN_ROLE, _0x6c6330._0x64b136);
        _0xad12da(STAKING_MANAGER_ROLE, _0x6c6330._0x6955e4);
        _0xad12da(ALLOCATOR_SERVICE_ROLE, _0x6c6330._0x259ceb);
        _0xad12da(INITIATOR_SERVICE_ROLE, _0x6c6330._0x6803c4);

        _0xd0dbf1(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xd0dbf1(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0xda536d = _0x6c6330._0xda536d;
        _0x01ebdc = _0x6c6330._0x01ebdc;
        _0xee46e5 = _0x6c6330._0xee46e5;
        _0xb58ab2 = _0x6c6330._0xb58ab2;
        _0x71c2df = _0x6c6330._0x71c2df;
        _0x8c61b3 = _0x6c6330._0x8c61b3;
        _0x341b0d = _0x6c6330._0x341b0d;

        _0xa05967 = 0.1 ether;
        _0xdde84c = 0.01 ether;
        _0x4619a0 = 32 ether;
        _0x8b8f24 = 32 ether;
        _0xf8acfe = true;
        _0xb70f7d = block.number;
        _0x3d4207 = 1024 ether;
    }

    function _0x5996df(ILiquidityBuffer _0x8723ea) public _0xcea592(2) {
        _0x810284 = _0x8723ea;
    }

    function _0x79a344(uint256 _0x499b0a) external payable {
        if (_0xb58ab2._0x677f02()) {
            revert Paused();
        }

        if (_0xf8acfe) {
            _0x46a399(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0xa05967) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x1504fc = _0x927416(msg.value);
        if (_0x1504fc + _0xda536d._0x8ea752() > _0x3d4207) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x1504fc < _0x499b0a) {
            revert StakeBelowMinimumMETHAmount(_0x1504fc, _0x499b0a);
        }

        _0x81bfef += msg.value;

        emit Staked(msg.sender, msg.value, _0x1504fc);
        _0xda536d._0x1b46a0(msg.sender, _0x1504fc);
    }

    function _0x5d35de(uint128 _0x0e5bbd, uint128 _0x1de5e4) external returns (uint256) {
        return _0x6dd254(_0x0e5bbd, _0x1de5e4);
    }

    function _0x8cad97(
        uint128 _0x0e5bbd,
        uint128 _0x1de5e4,
        uint256 _0xb709e8,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0xcdcae8(_0xda536d, msg.sender, address(this), _0x0e5bbd, _0xb709e8, v, r, s);
        return _0x6dd254(_0x0e5bbd, _0x1de5e4);
    }

    function _0x6dd254(uint128 _0x0e5bbd, uint128 _0x1de5e4) internal returns (uint256) {
        if (_0xb58ab2._0xc01798()) {
            revert Paused();
        }

        if (_0x0e5bbd < _0xdde84c) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0xe9899d = uint128(_0x3d97ad(_0x0e5bbd));
        if (_0xe9899d < _0x1de5e4) {
            revert UnstakeBelowMinimumETHAmount(_0xe9899d, _0x1de5e4);
        }

        uint256 _0xe44e0f =
            _0x8c61b3._0x5f486f({_0x23c72f: msg.sender, _0xa7799e: _0x0e5bbd, _0x98bad2: _0xe9899d});
        emit UnstakeRequested({_0xe62b08: _0xe44e0f, _0x839a24: msg.sender, _0xe9899d: _0xe9899d, _0xa7799e: _0x0e5bbd});

        SafeERC20Upgradeable._0xabfcdc(_0xda536d, msg.sender, address(_0x8c61b3), _0x0e5bbd);

        return _0xe44e0f;
    }

    function _0x927416(uint256 _0xe9899d) public view returns (uint256) {
        if (_0xda536d._0x8ea752() == 0) {
            return _0xe9899d;
        }
        uint256 _0xfac2d0 = Math._0xee1eb6(
            _0x990eb7(), _0x59a9ff + _0x40b219, _0x59a9ff
        );
        return Math._0xee1eb6(_0xe9899d, _0xda536d._0x8ea752(), _0xfac2d0);
    }

    function _0x3d97ad(uint256 _0x008b3e) public view returns (uint256) {
        if (_0xda536d._0x8ea752() == 0) {
            return _0x008b3e;
        }
        return Math._0xee1eb6(_0x008b3e, _0x990eb7(), _0xda536d._0x8ea752());
    }

    function _0x990eb7() public view returns (uint256) {
        OracleRecord memory _0x81d68b = _0xee46e5._0x04f469();
        uint256 _0xd14b20 = 0;
        _0xd14b20 += _0x81bfef;
        _0xd14b20 += _0xeeff52;
        _0xd14b20 += _0x757e81 - _0x81d68b._0x95713a;
        _0xd14b20 += _0x81d68b._0x2f06d9;
        _0xd14b20 += _0x810284._0x5676ae();
        _0xd14b20 -= _0x810284._0x78be08();
        _0xd14b20 += _0x8c61b3.balance();
        return _0xd14b20;
    }

    function _0x8be70a() external payable _0xfcde53 {
        emit ReturnsReceived(msg.value);
        _0x81bfef += msg.value;
    }

    function _0xad615a() external payable _0x52defb {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0x81bfef += msg.value;
    }

    modifier _0xfcde53() {
        if (msg.sender != _0x71c2df) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x52defb() {
        if (msg.sender != address(_0x810284)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0xe59d04() {
        if (msg.sender != address(_0x8c61b3)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x477df2(address _0x3e2456) {
        if (_0x3e2456 == address(0)) {
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