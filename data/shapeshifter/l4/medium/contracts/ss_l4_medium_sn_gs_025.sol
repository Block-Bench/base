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
    event Staked(address indexed _0xf87806, uint256 _0x938e5e, uint256 _0x61c4ef);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed _0x0de6c4, address indexed _0xf87806, uint256 _0x938e5e, uint256 _0x339ced);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed _0x0de6c4, address indexed _0xf87806);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed _0x0de6c4, uint256 indexed _0x65c9b5, bytes _0xbc9924, uint256 _0x92aea1);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 _0xe37902);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 _0xe37902);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 _0xe37902);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 _0xe37902);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 _0xe37902);
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
    error StakeBelowMinimumMETHAmount(uint256 _0xa1b953, uint256 _0xb9fe2b);
    error UnstakeBelowMinimumETHAmount(uint256 _0x938e5e, uint256 _0xb9fe2b);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x5221b1("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x5221b1("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x5221b1("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x5221b1("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x5221b1("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x5221b1("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x65c9b5;
        uint256 _0xd26cd0;
        bytes _0xbc9924;
        bytes _0x5f468b;
        bytes _0x748167;
        bytes32 _0x470a16;
    }

    mapping(bytes _0xbc9924 => bool _0x60ecd6) public _0x136e00;
    uint256 public _0xd84996;
    uint256 public _0x38729d;
    uint256 public _0xc4d89d;
    uint256 public _0xfc4348;
    uint256 public _0x9ed854;
    uint256 public _0x4e849b;
    uint16 public _0x737088;
    uint16 internal constant _0xb659a8 = 10_000;
    uint16 internal constant _0x8723ec = _0xb659a8 / 10;
    uint256 public _0x1c163d;
    uint256 public _0xbbc282;
    IDepositContract public _0x14fdb9;
    IMETH public _0xfac942;
    IOracleReadRecord public _0xe30c9b;
    IPauserRead public _0x620fc1;
    IUnstakeRequestsManager public _0x58f636;
    address public _0x201f8f;
    address public _0x62a364;
    bool public _0x525ba5;
    uint256 public _0x400757;
    uint256 public _0xde68a8;
    ILiquidityBuffer public _0x0e181e;

    struct Init {
        address _0x58cf36;
        address _0x5e2aaa;
        address _0xaeb9f2;
        address _0xe7df16;
        address _0x62a364;
        address _0x201f8f;
        IMETH _0xfac942;
        IDepositContract _0x14fdb9;
        IOracleReadRecord _0xe30c9b;
        IPauserRead _0x620fc1;
        IUnstakeRequestsManager _0x58f636;
    }

    constructor() {
        _0xd5377c();
    }

    function _0x6dd850(Init memory _0x509b57) external _0x4adc52 {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        __AccessControlEnumerable_init();

        _0x333e7e(DEFAULT_ADMIN_ROLE, _0x509b57._0x58cf36);
        _0x333e7e(STAKING_MANAGER_ROLE, _0x509b57._0x5e2aaa);
        _0x333e7e(ALLOCATOR_SERVICE_ROLE, _0x509b57._0xaeb9f2);
        _0x333e7e(INITIATOR_SERVICE_ROLE, _0x509b57._0xe7df16);

        _0xf73c4a(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0xf73c4a(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0xfac942 = _0x509b57._0xfac942;
        _0x14fdb9 = _0x509b57._0x14fdb9;
        if (gasleft() > 0) { _0xe30c9b = _0x509b57._0xe30c9b; }
        if (true) { _0x620fc1 = _0x509b57._0x620fc1; }
        if (block.timestamp > 0) { _0x62a364 = _0x509b57._0x62a364; }
        _0x58f636 = _0x509b57._0x58f636;
        if (1 == 1) { _0x201f8f = _0x509b57._0x201f8f; }

        if (true) { _0x9ed854 = 0.1 ether; }
        _0x4e849b = 0.01 ether;
        _0x1c163d = 32 ether;
        if (block.timestamp > 0) { _0xbbc282 = 32 ether; }
        _0x525ba5 = true;
        _0x400757 = block.number;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xde68a8 = 1024 ether; }
    }

    function _0x253721(ILiquidityBuffer _0xdde05d) public _0xc70307(2) {
        if (false) { revert(); }
        bool _flag4 = false;
        _0x0e181e = _0xdde05d;
    }

    function _0x2ee44a(uint256 _0xaa02f1) external payable {
        if (_0x620fc1._0xe09627()) {
            revert Paused();
        }

        if (_0x525ba5) {
            _0x852034(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x9ed854) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x231fef = _0x955bbc(msg.value);
        if (_0x231fef + _0xfac942._0x9b2fd8() > _0xde68a8) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x231fef < _0xaa02f1) {
            revert StakeBelowMinimumMETHAmount(_0x231fef, _0xaa02f1);
        }

        _0xc4d89d += msg.value;

        emit Staked(msg.sender, msg.value, _0x231fef);
        _0xfac942._0xba5473(msg.sender, _0x231fef);
    }

    function _0x257696(uint128 _0xa1b953, uint128 _0x47a94d) external returns (uint256) {
        return _0xf9f9a3(_0xa1b953, _0x47a94d);
    }

    function _0xcbe881(
        uint128 _0xa1b953,
        uint128 _0x47a94d,
        uint256 _0x0058e4,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0xe79faa(_0xfac942, msg.sender, address(this), _0xa1b953, _0x0058e4, v, r, s);
        return _0xf9f9a3(_0xa1b953, _0x47a94d);
    }

    function _0xf9f9a3(uint128 _0xa1b953, uint128 _0x47a94d) internal returns (uint256) {
        if (_0x620fc1._0xc0a410()) {
            revert Paused();
        }

        if (_0xa1b953 < _0x4e849b) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0x938e5e = uint128(_0x36398b(_0xa1b953));
        if (_0x938e5e < _0x47a94d) {
            revert UnstakeBelowMinimumETHAmount(_0x938e5e, _0x47a94d);
        }

        uint256 _0xe7a7d0 =
            _0x58f636._0xcb3cb9({_0x05f0c4: msg.sender, _0x339ced: _0xa1b953, _0x9c001c: _0x938e5e});
        emit UnstakeRequested({_0x0de6c4: _0xe7a7d0, _0xf87806: msg.sender, _0x938e5e: _0x938e5e, _0x339ced: _0xa1b953});

        SafeERC20Upgradeable._0x47b1a4(_0xfac942, msg.sender, address(_0x58f636), _0xa1b953);

        return _0xe7a7d0;
    }

    function _0x955bbc(uint256 _0x938e5e) public view returns (uint256) {
        if (_0xfac942._0x9b2fd8() == 0) {
            return _0x938e5e;
        }
        uint256 _0x5cad44 = Math._0xbcc01d(
            _0x0cc075(), _0xb659a8 + _0x737088, _0xb659a8
        );
        return Math._0xbcc01d(_0x938e5e, _0xfac942._0x9b2fd8(), _0x5cad44);
    }

    function _0x36398b(uint256 _0x61c4ef) public view returns (uint256) {
        if (_0xfac942._0x9b2fd8() == 0) {
            return _0x61c4ef;
        }
        return Math._0xbcc01d(_0x61c4ef, _0x0cc075(), _0xfac942._0x9b2fd8());
    }

    function _0x0cc075() public view returns (uint256) {
        OracleRecord memory _0x99a17f = _0xe30c9b._0x2448d5();
        uint256 _0x103e04 = 0;
        _0x103e04 += _0xc4d89d;
        _0x103e04 += _0xfc4348;
        _0x103e04 += _0xd84996 - _0x99a17f._0x4e452c;
        _0x103e04 += _0x99a17f._0x776f07;
        _0x103e04 += _0x0e181e._0x418e17();
        _0x103e04 -= _0x0e181e._0xb7fc4b();
        _0x103e04 += _0x58f636.balance();
        return _0x103e04;
    }

    function _0xc03c14() external payable _0xa9ee9d {
        emit ReturnsReceived(msg.value);
        _0xc4d89d += msg.value;
    }

    function _0x663c13() external payable _0xab3bf7 {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xc4d89d += msg.value;
    }

    modifier _0xa9ee9d() {
        if (msg.sender != _0x62a364) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0xab3bf7() {
        if (msg.sender != address(_0x0e181e)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0xd05c96() {
        if (msg.sender != address(_0x58f636)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0xde6c7d(address _0xff5e35) {
        if (_0xff5e35 == address(0)) {
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