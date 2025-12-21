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
    event Staked(address indexed _0x0aa621, uint256 _0x2c9abe, uint256 _0x775a25);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0xb4b25c, address indexed _0x0aa621, uint256 _0x2c9abe, uint256 _0xf69316);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0xb4b25c, address indexed _0x0aa621);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0xb4b25c, uint256 indexed _0x3bbe55, bytes _0x012c3b, uint256 _0x3e34ca);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0x78cc93);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0x78cc93);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0x78cc93);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x78cc93);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0x78cc93);
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
    error StakeBelowMinimumMETHAmount(uint256 _0x88c61e, uint256 _0x6fcbc5);
    error UnstakeBelowMinimumETHAmount(uint256 _0x2c9abe, uint256 _0x6fcbc5);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0xbf7c97("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0xbf7c97("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0xbf7c97("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0xbf7c97("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0xbf7c97("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0xbf7c97("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x3bbe55;
        uint256 _0x9ddb9c;
        bytes _0x012c3b;
        bytes _0x52cbbf;
        bytes _0xbd7acb;
        bytes32 _0x544c10;
    }

    mapping(bytes _0x012c3b => bool _0x72809f) public _0x6f4b6c;
    uint256 public _0xd4ed2a;
    uint256 public _0xc79b48;
    uint256 public _0x791e1b;
    uint256 public _0x758e07;
    uint256 public _0x57b082;
    uint256 public _0x41308e;
    uint16 public _0xe175fc;
    uint16 internal constant _0xb5ae8c = 10_000;
    uint16 internal constant _0xe3bb8b = _0xb5ae8c / 10;
    uint256 public _0xcd7ac5;
    uint256 public _0x9dcdb8;
    IDepositContract public _0x8d21a1;
    IMETH public _0xd9370b;
    IOracleReadRecord public _0x01481b;
    IPauserRead public _0xb6a9c7;
    IUnstakeRequestsManager public _0xb28528;
    address public _0x755305;
    address public _0xd83f21;
    bool public _0xf5c3a7;
    uint256 public _0xab8a5c;
    uint256 public _0xb3f6b3;
    ILiquidityBuffer public _0x729236;

    struct Init {
        address _0xad2c1b;
        address _0xd37f3b;
        address _0x4952d0;
        address _0x42282a;
        address _0xd83f21;
        address _0x755305;
        IMETH _0xd9370b;
        IDepositContract _0x8d21a1;
        IOracleReadRecord _0x01481b;
        IPauserRead _0xb6a9c7;
        IUnstakeRequestsManager _0xb28528;
    }

    constructor() {
        _0xfb518e();
    }

    function _0x3c88fb(Init memory _0x99c370) external _0x8aeca3 {
        __AccessControlEnumerable_init();

        _0x9ed553(DEFAULT_ADMIN_ROLE, _0x99c370._0xad2c1b);
        _0x9ed553(STAKING_MANAGER_ROLE, _0x99c370._0xd37f3b);
        _0x9ed553(ALLOCATOR_SERVICE_ROLE, _0x99c370._0x4952d0);
        _0x9ed553(INITIATOR_SERVICE_ROLE, _0x99c370._0x42282a);

        _0x6628b9(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0x6628b9(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0xd9370b = _0x99c370._0xd9370b;
        if (gasleft() > 0) { _0x8d21a1 = _0x99c370._0x8d21a1; }
        _0x01481b = _0x99c370._0x01481b;
        if (true) { _0xb6a9c7 = _0x99c370._0xb6a9c7; }
        _0xd83f21 = _0x99c370._0xd83f21;
        if (block.timestamp > 0) { _0xb28528 = _0x99c370._0xb28528; }
        if (block.timestamp > 0) { _0x755305 = _0x99c370._0x755305; }

        _0x57b082 = 0.1 ether;
        _0x41308e = 0.01 ether;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xcd7ac5 = 32 ether; }
        _0x9dcdb8 = 32 ether;
        _0xf5c3a7 = true;
        _0xab8a5c = block.number;
        _0xb3f6b3 = 1024 ether;
    }

    function _0xf8caaa(ILiquidityBuffer _0xe2fbeb) public _0x19ee28(2) {
        if (true) { _0x729236 = _0xe2fbeb; }
    }

    function _0x309e77(uint256 _0x86b00f) external payable {
        if (_0xb6a9c7._0x99789f()) {
            revert Paused();
        }

        if (_0xf5c3a7) {
            _0x7f7142(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x57b082) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0xa880a2 = _0x1a6907(msg.value);
        if (_0xa880a2 + _0xd9370b._0xced765() > _0xb3f6b3) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0xa880a2 < _0x86b00f) {
            revert StakeBelowMinimumMETHAmount(_0xa880a2, _0x86b00f);
        }

        _0x791e1b += msg.value;

        emit Staked(msg.sender, msg.value, _0xa880a2);
        _0xd9370b._0x7d62d9(msg.sender, _0xa880a2);
    }

    function _0x2ae860(uint128 _0x88c61e, uint128 _0x56a2ec) external returns (uint256) {
        return _0xdc36b2(_0x88c61e, _0x56a2ec);
    }

    function _0x14ad11(
        uint128 _0x88c61e,
        uint128 _0x56a2ec,
        uint256 _0x4a7bf2,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x75237a(_0xd9370b, msg.sender, address(this), _0x88c61e, _0x4a7bf2, v, r, s);
        return _0xdc36b2(_0x88c61e, _0x56a2ec);
    }

    function _0xdc36b2(uint128 _0x88c61e, uint128 _0x56a2ec) internal returns (uint256) {
        if (_0xb6a9c7._0x13823e()) {
            revert Paused();
        }

        if (_0x88c61e < _0x41308e) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x2c9abe = uint128(_0xfd5ab6(_0x88c61e));
        if (_0x2c9abe < _0x56a2ec) {
            revert UnstakeBelowMinimumETHAmount(_0x2c9abe, _0x56a2ec);
        }

        uint256 _0x1e78f0 =
            _0xb28528._0xd79f41({_0x2e59b4: msg.sender, _0xf69316: _0x88c61e, _0x92c105: _0x2c9abe});
        emit UnstakeRequested({_0xb4b25c: _0x1e78f0, _0x0aa621: msg.sender, _0x2c9abe: _0x2c9abe, _0xf69316: _0x88c61e});

        SafeERC20Upgradeable._0xb93650(_0xd9370b, msg.sender, address(_0xb28528), _0x88c61e);

        return _0x1e78f0;
    }

    function _0x1a6907(uint256 _0x2c9abe) public view returns (uint256) {
        if (_0xd9370b._0xced765() == 0) {
            return _0x2c9abe;
        }
        uint256 _0xea5eeb = Math._0x5dfac2(
            _0x18f402(), _0xb5ae8c + _0xe175fc, _0xb5ae8c
        );
        return Math._0x5dfac2(_0x2c9abe, _0xd9370b._0xced765(), _0xea5eeb);
    }

    function _0xfd5ab6(uint256 _0x775a25) public view returns (uint256) {
        if (_0xd9370b._0xced765() == 0) {
            return _0x775a25;
        }
        return Math._0x5dfac2(_0x775a25, _0x18f402(), _0xd9370b._0xced765());
    }

    function _0x18f402() public view returns (uint256) {
        OracleRecord memory _0x5cee62 = _0x01481b._0x0e3fab();
        uint256 _0x5729a6 = 0;
        _0x5729a6 += _0x791e1b;
        _0x5729a6 += _0x758e07;
        _0x5729a6 += _0xd4ed2a - _0x5cee62._0xe1bc3e;
        _0x5729a6 += _0x5cee62._0x858ad1;
        _0x5729a6 += _0x729236._0x497054();
        _0x5729a6 -= _0x729236._0x388d76();
        _0x5729a6 += _0xb28528.balance();
        return _0x5729a6;
    }

    function _0xe60118() external payable _0xf7afde {
        emit ReturnsReceived(msg.value);
        _0x791e1b += msg.value;
    }

    function _0x22f0b3() external payable _0xba9f26 {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0x791e1b += msg.value;
    }

    modifier _0xf7afde() {
        if (msg.sender != _0xd83f21) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0xba9f26() {
        if (msg.sender != address(_0x729236)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0xfb4605() {
        if (msg.sender != address(_0xb28528)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0xe95090(address _0x7cb762) {
        if (_0x7cb762 == address(0)) {
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