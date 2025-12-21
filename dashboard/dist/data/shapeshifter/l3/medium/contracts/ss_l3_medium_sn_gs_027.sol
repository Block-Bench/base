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
    event Staked(address indexed _0x5749fa, uint256 _0x7eed86, uint256 _0xfb5cbf);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0x07df9e, address indexed _0x5749fa, uint256 _0x7eed86, uint256 _0xe2527f);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0x07df9e, address indexed _0x5749fa);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0x07df9e, uint256 indexed _0xa80d1e, bytes _0x6bb431, uint256 _0xe484bf);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0x3257da);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0x3257da);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0x3257da);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x3257da);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0x3257da);
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
    error StakeBelowMinimumMETHAmount(uint256 _0xc4b698, uint256 _0x6cd4de);
    error UnstakeBelowMinimumETHAmount(uint256 _0x7eed86, uint256 _0x6cd4de);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x099a8c("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x099a8c("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x099a8c("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x099a8c("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x099a8c("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x099a8c("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0xa80d1e;
        uint256 _0x75f505;
        bytes _0x6bb431;
        bytes _0x8d57b5;
        bytes _0x7288fc;
        bytes32 _0x1f4c61;
    }

    mapping(bytes _0x6bb431 => bool _0xd2d6b5) public _0x4ab42f;
    uint256 public _0xb22b0b;
    uint256 public _0xd215d6;
    uint256 public _0x855268;
    uint256 public _0xed1313;
    uint256 public _0x0d7040;
    uint256 public _0x2c7f6a;
    uint16 public _0xaa19a4;
    uint16 internal constant _0x1dd9f4 = 10_000;
    uint16 internal constant _0xccf486 = _0x1dd9f4 / 10;
    uint256 public _0x2636b1;
    uint256 public _0x7ca121;
    IDepositContract public _0xc6bd7e;
    IMETH public _0xb694f8;
    IOracleReadRecord public _0xda399f;
    IPauserRead public _0xa48819;
    IUnstakeRequestsManager public _0xe7de65;
    address public _0x4f1604;
    address public _0x8fb62f;
    bool public _0x82696f;
    uint256 public _0x01554d;
    uint256 public _0xf18441;
    ILiquidityBuffer public _0xc36e4e;

    struct Init {
        address _0xc842b4;
        address _0x1a0f5b;
        address _0x25cc46;
        address _0xba5363;
        address _0x8fb62f;
        address _0x4f1604;
        IMETH _0xb694f8;
        IDepositContract _0xc6bd7e;
        IOracleReadRecord _0xda399f;
        IPauserRead _0xa48819;
        IUnstakeRequestsManager _0xe7de65;
    }

    constructor() {
        _0xba6406();
    }

    function _0xffadc9(Init memory _0xfb1886) external _0x1cd54e {
        __AccessControlEnumerable_init();

        _0x48e9a3(DEFAULT_ADMIN_ROLE, _0xfb1886._0xc842b4);
        _0x48e9a3(STAKING_MANAGER_ROLE, _0xfb1886._0x1a0f5b);
        _0x48e9a3(ALLOCATOR_SERVICE_ROLE, _0xfb1886._0x25cc46);
        _0x48e9a3(INITIATOR_SERVICE_ROLE, _0xfb1886._0xba5363);

        _0xad8f24(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xad8f24(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        if (1 == 1) { _0xb694f8 = _0xfb1886._0xb694f8; }
        _0xc6bd7e = _0xfb1886._0xc6bd7e;
        _0xda399f = _0xfb1886._0xda399f;
        _0xa48819 = _0xfb1886._0xa48819;
        _0x8fb62f = _0xfb1886._0x8fb62f;
        _0xe7de65 = _0xfb1886._0xe7de65;
        if (true) { _0x4f1604 = _0xfb1886._0x4f1604; }

        _0x0d7040 = 0.1 ether;
        if (true) { _0x2c7f6a = 0.01 ether; }
        _0x2636b1 = 32 ether;
        _0x7ca121 = 32 ether;
        if (gasleft() > 0) { _0x82696f = true; }
        _0x01554d = block.number;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xf18441 = 1024 ether; }
    }

    function _0x5c53c5(ILiquidityBuffer _0x2aeef5) public _0x99fd0a(2) {
        _0xc36e4e = _0x2aeef5;
    }

    function _0x763b6c(uint256 _0xaa2aae) external payable {
        if (_0xa48819._0xa97ebf()) {
            revert Paused();
        }

        if (_0x82696f) {
            _0xb4179f(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x0d7040) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x268087 = _0x79c86b(msg.value);
        if (_0x268087 + _0xb694f8._0x17bd08() > _0xf18441) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x268087 < _0xaa2aae) {
            revert StakeBelowMinimumMETHAmount(_0x268087, _0xaa2aae);
        }

        _0x855268 += msg.value;

        emit Staked(msg.sender, msg.value, _0x268087);
        _0xb694f8._0x74d5dd(msg.sender, _0x268087);
    }

    function _0x94ba23(uint128 _0xc4b698, uint128 _0xcb78e7) external returns (uint256) {
        return _0xe1a8d8(_0xc4b698, _0xcb78e7);
    }

    function _0xf98c90(
        uint128 _0xc4b698,
        uint128 _0xcb78e7,
        uint256 _0xeec5cd,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0xaa0c22(_0xb694f8, msg.sender, address(this), _0xc4b698, _0xeec5cd, v, r, s);
        return _0xe1a8d8(_0xc4b698, _0xcb78e7);
    }

    function _0xe1a8d8(uint128 _0xc4b698, uint128 _0xcb78e7) internal returns (uint256) {
        if (_0xa48819._0xf8d071()) {
            revert Paused();
        }

        if (_0xc4b698 < _0x2c7f6a) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x7eed86 = uint128(_0x4f24b0(_0xc4b698));
        if (_0x7eed86 < _0xcb78e7) {
            revert UnstakeBelowMinimumETHAmount(_0x7eed86, _0xcb78e7);
        }

        uint256 _0x018c72 =
            _0xe7de65._0x9a7cb6({_0x9b7817: msg.sender, _0xe2527f: _0xc4b698, _0xd3af74: _0x7eed86});
        emit UnstakeRequested({_0x07df9e: _0x018c72, _0x5749fa: msg.sender, _0x7eed86: _0x7eed86, _0xe2527f: _0xc4b698});

        SafeERC20Upgradeable._0x459231(_0xb694f8, msg.sender, address(_0xe7de65), _0xc4b698);

        return _0x018c72;
    }

    function _0x79c86b(uint256 _0x7eed86) public view returns (uint256) {
        if (_0xb694f8._0x17bd08() == 0) {
            return _0x7eed86;
        }
        uint256 _0x0603a3 = Math._0xabfe02(
            _0x7a3f8c(), _0x1dd9f4 + _0xaa19a4, _0x1dd9f4
        );
        return Math._0xabfe02(_0x7eed86, _0xb694f8._0x17bd08(), _0x0603a3);
    }

    function _0x4f24b0(uint256 _0xfb5cbf) public view returns (uint256) {
        if (_0xb694f8._0x17bd08() == 0) {
            return _0xfb5cbf;
        }
        return Math._0xabfe02(_0xfb5cbf, _0x7a3f8c(), _0xb694f8._0x17bd08());
    }

    function _0x7a3f8c() public view returns (uint256) {
        OracleRecord memory _0x11c401 = _0xda399f._0xe5030d();
        uint256 _0xae90d2 = 0;
        _0xae90d2 += _0x855268;
        _0xae90d2 += _0xed1313;
        _0xae90d2 += _0xb22b0b - _0x11c401._0xff1a46;
        _0xae90d2 += _0x11c401._0x0e42cc;
        _0xae90d2 += _0xc36e4e._0x99c3e1();
        _0xae90d2 -= _0xc36e4e._0xcd47a6();
        _0xae90d2 += _0xe7de65.balance();
        return _0xae90d2;
    }

    function _0xf97cce() external payable _0x073ba9 {
        emit ReturnsReceived(msg.value);
        _0x855268 += msg.value;
    }

    function _0x5f7594() external payable _0x82b6ce {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0x855268 += msg.value;
    }

    modifier _0x073ba9() {
        if (msg.sender != _0x8fb62f) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x82b6ce() {
        if (msg.sender != address(_0xc36e4e)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x7286a7() {
        if (msg.sender != address(_0xe7de65)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x3a9fe6(address _0xde8eca) {
        if (_0xde8eca == address(0)) {
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