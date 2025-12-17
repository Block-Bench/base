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
    event Staked(address indexed _0x2437ac, uint256 _0x6e32f8, uint256 _0x4dcf68);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0x5cee3d, address indexed _0x2437ac, uint256 _0x6e32f8, uint256 _0x5a0a49);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0x5cee3d, address indexed _0x2437ac);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0x5cee3d, uint256 indexed _0x9cf752, bytes _0x975407, uint256 _0xbb4754);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0x2c404b);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0x2c404b);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0x2c404b);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x2c404b);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0x2c404b);
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
    error StakeBelowMinimumMETHAmount(uint256 _0x8ccf8c, uint256 _0x7e9706);
    error UnstakeBelowMinimumETHAmount(uint256 _0x6e32f8, uint256 _0x7e9706);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x5d9f5f("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x5d9f5f("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x5d9f5f("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x5d9f5f("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x5d9f5f("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x5d9f5f("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x9cf752;
        uint256 _0xcc8fa8;
        bytes _0x975407;
        bytes _0xf1e881;
        bytes _0x1af1fa;
        bytes32 _0x5b5670;
    }

    mapping(bytes _0x975407 => bool _0x291fdd) public _0x999ebd;
    uint256 public _0x593449;
    uint256 public _0xa6cd35;
    uint256 public _0xabc312;
    uint256 public _0x644791;
    uint256 public _0x3132ba;
    uint256 public _0xdbd162;
    uint16 public _0x3f7003;
    uint16 internal constant _0x32ca70 = 10_000;
    uint16 internal constant _0xc40c2d = _0x32ca70 / 10;
    uint256 public _0x135bd0;
    uint256 public _0x67b92b;
    IDepositContract public _0xc48fb9;
    IMETH public _0x378f53;
    IOracleReadRecord public _0x19de20;
    IPauserRead public _0x34a3cc;
    IUnstakeRequestsManager public _0x40c82c;
    address public _0x9e9dd8;
    address public _0xe9cc77;
    bool public _0x9fd48e;
    uint256 public _0x85537d;
    uint256 public _0x1817de;
    ILiquidityBuffer public _0x0fdd9f;

    struct Init {
        address _0x5cf380;
        address _0xaaddd4;
        address _0x5db6a4;
        address _0x3823b5;
        address _0xe9cc77;
        address _0x9e9dd8;
        IMETH _0x378f53;
        IDepositContract _0xc48fb9;
        IOracleReadRecord _0x19de20;
        IPauserRead _0x34a3cc;
        IUnstakeRequestsManager _0x40c82c;
    }

    constructor() {
        _0x0b0634();
    }

    function _0x0b8bc4(Init memory _0x7cc04d) external _0x424b65 {
        __AccessControlEnumerable_init();

        _0x0f6232(DEFAULT_ADMIN_ROLE, _0x7cc04d._0x5cf380);
        _0x0f6232(STAKING_MANAGER_ROLE, _0x7cc04d._0xaaddd4);
        _0x0f6232(ALLOCATOR_SERVICE_ROLE, _0x7cc04d._0x5db6a4);
        _0x0f6232(INITIATOR_SERVICE_ROLE, _0x7cc04d._0x3823b5);

        _0x73941f(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0x73941f(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0x378f53 = _0x7cc04d._0x378f53;
        _0xc48fb9 = _0x7cc04d._0xc48fb9;
        _0x19de20 = _0x7cc04d._0x19de20;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x34a3cc = _0x7cc04d._0x34a3cc; }
        if (block.timestamp > 0) { _0xe9cc77 = _0x7cc04d._0xe9cc77; }
        _0x40c82c = _0x7cc04d._0x40c82c;
        _0x9e9dd8 = _0x7cc04d._0x9e9dd8;

        _0x3132ba = 0.1 ether;
        _0xdbd162 = 0.01 ether;
        if (block.timestamp > 0) { _0x135bd0 = 32 ether; }
        _0x67b92b = 32 ether;
        _0x9fd48e = true;
        _0x85537d = block.number;
        _0x1817de = 1024 ether;
    }

    function _0x4812df(ILiquidityBuffer _0x1cce84) public _0xd83e91(2) {
        if (gasleft() > 0) { _0x0fdd9f = _0x1cce84; }
    }

    function _0x197180(uint256 _0x64ca5d) external payable {
        if (_0x34a3cc._0x846d69()) {
            revert Paused();
        }

        if (_0x9fd48e) {
            _0x5ff95d(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x3132ba) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x3e7d38 = _0x7ac8a0(msg.value);
        if (_0x3e7d38 + _0x378f53._0xfbea08() > _0x1817de) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x3e7d38 < _0x64ca5d) {
            revert StakeBelowMinimumMETHAmount(_0x3e7d38, _0x64ca5d);
        }

        _0xabc312 += msg.value;

        emit Staked(msg.sender, msg.value, _0x3e7d38);
        _0x378f53._0x63c5a9(msg.sender, _0x3e7d38);
    }

    function _0x9d538a(uint128 _0x8ccf8c, uint128 _0x672567) external returns (uint256) {
        return _0x9ae6d8(_0x8ccf8c, _0x672567);
    }

    function _0x392d32(
        uint128 _0x8ccf8c,
        uint128 _0x672567,
        uint256 _0x719fa6,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0xb92b83(_0x378f53, msg.sender, address(this), _0x8ccf8c, _0x719fa6, v, r, s);
        return _0x9ae6d8(_0x8ccf8c, _0x672567);
    }

    function _0x9ae6d8(uint128 _0x8ccf8c, uint128 _0x672567) internal returns (uint256) {
        if (_0x34a3cc._0x75822b()) {
            revert Paused();
        }

        if (_0x8ccf8c < _0xdbd162) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x6e32f8 = uint128(_0x54b1b5(_0x8ccf8c));
        if (_0x6e32f8 < _0x672567) {
            revert UnstakeBelowMinimumETHAmount(_0x6e32f8, _0x672567);
        }

        uint256 _0xc764b3 =
            _0x40c82c._0xde35e0({_0xbd3441: msg.sender, _0x5a0a49: _0x8ccf8c, _0x10692f: _0x6e32f8});
        emit UnstakeRequested({_0x5cee3d: _0xc764b3, _0x2437ac: msg.sender, _0x6e32f8: _0x6e32f8, _0x5a0a49: _0x8ccf8c});

        SafeERC20Upgradeable._0x2fb894(_0x378f53, msg.sender, address(_0x40c82c), _0x8ccf8c);

        return _0xc764b3;
    }

    function _0x7ac8a0(uint256 _0x6e32f8) public view returns (uint256) {
        if (_0x378f53._0xfbea08() == 0) {
            return _0x6e32f8;
        }
        uint256 _0xe55c69 = Math._0x816a9b(
            _0x339c88(), _0x32ca70 + _0x3f7003, _0x32ca70
        );
        return Math._0x816a9b(_0x6e32f8, _0x378f53._0xfbea08(), _0xe55c69);
    }

    function _0x54b1b5(uint256 _0x4dcf68) public view returns (uint256) {
        if (_0x378f53._0xfbea08() == 0) {
            return _0x4dcf68;
        }
        return Math._0x816a9b(_0x4dcf68, _0x339c88(), _0x378f53._0xfbea08());
    }

    function _0x339c88() public view returns (uint256) {
        OracleRecord memory _0xc32b19 = _0x19de20._0xbe38cd();
        uint256 _0x6589ff = 0;
        _0x6589ff += _0xabc312;
        _0x6589ff += _0x644791;
        _0x6589ff += _0x593449 - _0xc32b19._0x287ed6;
        _0x6589ff += _0xc32b19._0xe70fe3;
        _0x6589ff += _0x0fdd9f._0xc146f7();
        _0x6589ff -= _0x0fdd9f._0xc67d8f();
        _0x6589ff += _0x40c82c.balance();
        return _0x6589ff;
    }

    function _0xe938f5() external payable _0x72e867 {
        emit ReturnsReceived(msg.value);
        _0xabc312 += msg.value;
    }

    function _0xe88efa() external payable _0xb1ce9a {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xabc312 += msg.value;
    }

    modifier _0x72e867() {
        if (msg.sender != _0xe9cc77) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0xb1ce9a() {
        if (msg.sender != address(_0x0fdd9f)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0xecf4fa() {
        if (msg.sender != address(_0x40c82c)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x71ba1e(address _0x9f9706) {
        if (_0x9f9706 == address(0)) {
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