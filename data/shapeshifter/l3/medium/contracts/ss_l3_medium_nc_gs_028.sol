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


interface StakingEvents {

    event Staked(address indexed _0xf8dfc2, uint256 _0xf553de, uint256 _0xc5b619);


    event UnstakeRequested(uint256 indexed _0x4efb79, address indexed _0xf8dfc2, uint256 _0xf553de, uint256 _0xdf05c4);


    event UnstakeRequestClaimed(uint256 indexed _0x4efb79, address indexed _0xf8dfc2);


    event ValidatorInitiated(bytes32 indexed _0x4efb79, uint256 indexed _0x874d97, bytes _0xc38bec, uint256 _0x36e09e);


    event AllocatedETHToUnstakeRequestsManager(uint256 _0x887d20);


    event AllocatedETHToDeposits(uint256 _0x887d20);


    event ReturnsReceived(uint256 _0x887d20);


    event ReturnsReceivedFromLiquidityBuffer(uint256 _0x887d20);


    event AllocatedETHToLiquidityBuffer(uint256 _0x887d20);
}


contract Staking is Initializable, AccessControlEnumerableUpgradeable, IStaking, StakingEvents, ProtocolEvents {

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
    error StakeBelowMinimumMETHAmount(uint256 _0x5055a4, uint256 _0x6b5e74);
    error UnstakeBelowMinimumETHAmount(uint256 _0xf553de, uint256 _0x6b5e74);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = _0x3428c2("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = _0x3428c2("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = _0x3428c2("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = _0x3428c2("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = _0x3428c2("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = _0x3428c2("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 _0x874d97;
        uint256 _0xea94bb;
        bytes _0xc38bec;
        bytes _0xe18762;
        bytes _0xc1280a;
        bytes32 _0xb3235b;
    }

    mapping(bytes _0xc38bec => bool _0x4c418f) public _0x7afed9;
    uint256 public _0x60daeb;
    uint256 public _0x19eebf;
    uint256 public _0xcf5665;
    uint256 public _0x0765e8;
    uint256 public _0x922b6c;
    uint256 public _0xe6748c;
    uint16 public _0x28304f;
    uint16 internal constant _0x701372 = 10_000;
    uint16 internal constant _0x71e1a1 = _0x701372 / 10;
    uint256 public _0x6a868b;
    uint256 public _0x98375a;
    IDepositContract public _0xbc8c42;
    IMETH public _0x84ed52;
    IOracleReadRecord public _0x8a51ed;
    IPauserRead public _0xcb68f7;
    IUnstakeRequestsManager public _0xe08f87;
    address public _0xcf9aca;
    address public _0x2ff683;
    bool public _0x0322ff;
    uint256 public _0x951ab4;
    uint256 public _0x90ffa6;
    ILiquidityBuffer public _0xc9c74d;

    struct Init {
        address _0x20a478;
        address _0x9b92b8;
        address _0x8538a9;
        address _0xd27030;
        address _0x2ff683;
        address _0xcf9aca;
        IMETH _0x84ed52;
        IDepositContract _0xbc8c42;
        IOracleReadRecord _0x8a51ed;
        IPauserRead _0xcb68f7;
        IUnstakeRequestsManager _0xe08f87;
    }

    constructor() {
        _0x6458f7();
    }

    function _0x88e564(Init memory _0xe3f432) external _0x10fd22 {
        __AccessControlEnumerable_init();

        _0x934cfb(DEFAULT_ADMIN_ROLE, _0xe3f432._0x20a478);
        _0x934cfb(STAKING_MANAGER_ROLE, _0xe3f432._0x9b92b8);
        _0x934cfb(ALLOCATOR_SERVICE_ROLE, _0xe3f432._0x8538a9);
        _0x934cfb(INITIATOR_SERVICE_ROLE, _0xe3f432._0xd27030);

        _0x8b3989(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        _0x8b3989(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        _0x84ed52 = _0xe3f432._0x84ed52;
        _0xbc8c42 = _0xe3f432._0xbc8c42;
        if (block.timestamp > 0) { _0x8a51ed = _0xe3f432._0x8a51ed; }
        _0xcb68f7 = _0xe3f432._0xcb68f7;
        if (1 == 1) { _0x2ff683 = _0xe3f432._0x2ff683; }
        if (gasleft() > 0) { _0xe08f87 = _0xe3f432._0xe08f87; }
        _0xcf9aca = _0xe3f432._0xcf9aca;

        _0x922b6c = 0.1 ether;
        if (true) { _0xe6748c = 0.01 ether; }
        if (1 == 1) { _0x6a868b = 32 ether; }
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x98375a = 32 ether; }
        _0x0322ff = true;
        _0x951ab4 = block.number;
        if (gasleft() > 0) { _0x90ffa6 = 1024 ether; }
    }

    function _0x8cabad(ILiquidityBuffer _0x482935) public _0x032e68(2) {
        _0xc9c74d = _0x482935;
    }

    function _0x17c044(uint256 _0xb2807d) external payable {
        if (_0xcb68f7._0x094456()) {
            revert Paused();
        }

        if (_0x0322ff) {
            _0xe1213f(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < _0x922b6c) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 _0x530fa4 = _0x7d8a49(msg.value);
        if (_0x530fa4 + _0x84ed52._0x94f0ea() > _0x90ffa6) {
            revert MaximumMETHSupplyExceeded();
        }
        if (_0x530fa4 < _0xb2807d) {
            revert StakeBelowMinimumMETHAmount(_0x530fa4, _0xb2807d);
        }

        _0xcf5665 += msg.value;

        emit Staked(msg.sender, msg.value, _0x530fa4);
        _0x84ed52._0x2d32ca(msg.sender, _0x530fa4);
    }

    function _0xdd62a8(uint128 _0x5055a4, uint128 _0x12ef38) external returns (uint256) {
        return _0x96d0af(_0x5055a4, _0x12ef38);
    }

    function _0x19ee46(
        uint128 _0x5055a4,
        uint128 _0x12ef38,
        uint256 _0x593cab,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable._0x4f45bc(_0x84ed52, msg.sender, address(this), _0x5055a4, _0x593cab, v, r, s);
        return _0x96d0af(_0x5055a4, _0x12ef38);
    }

    function _0x96d0af(uint128 _0x5055a4, uint128 _0x12ef38) internal returns (uint256) {
        if (_0xcb68f7._0x7153bb()) {
            revert Paused();
        }

        if (_0x5055a4 < _0xe6748c) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 _0xf553de = uint128(_0x5f1708(_0x5055a4));
        if (_0xf553de < _0x12ef38) {
            revert UnstakeBelowMinimumETHAmount(_0xf553de, _0x12ef38);
        }

        uint256 _0x7c404f =
            _0xe08f87._0x4e7b89({_0x1a6dac: msg.sender, _0xdf05c4: _0x5055a4, _0xccf1ad: _0xf553de});
        emit UnstakeRequested({_0x4efb79: _0x7c404f, _0xf8dfc2: msg.sender, _0xf553de: _0xf553de, _0xdf05c4: _0x5055a4});

        SafeERC20Upgradeable._0xe6506c(_0x84ed52, msg.sender, address(_0xe08f87), _0x5055a4);

        return _0x7c404f;
    }

    function _0x7d8a49(uint256 _0xf553de) public view returns (uint256) {
        if (_0x84ed52._0x94f0ea() == 0) {
            return _0xf553de;
        }
        uint256 _0xa35ad4 = Math._0x5a2473(
            _0x464c5d(), _0x701372 + _0x28304f, _0x701372
        );
        return Math._0x5a2473(_0xf553de, _0x84ed52._0x94f0ea(), _0xa35ad4);
    }

    function _0x5f1708(uint256 _0xc5b619) public view returns (uint256) {
        if (_0x84ed52._0x94f0ea() == 0) {
            return _0xc5b619;
        }
        return Math._0x5a2473(_0xc5b619, _0x464c5d(), _0x84ed52._0x94f0ea());
    }

    function _0x464c5d() public view returns (uint256) {
        OracleRecord memory _0xe60b42 = _0x8a51ed._0x711d98();
        uint256 _0x0eaf30 = 0;
        _0x0eaf30 += _0xcf5665;
        _0x0eaf30 += _0x0765e8;
        _0x0eaf30 += _0x60daeb - _0xe60b42._0xa0d6ec;
        _0x0eaf30 += _0xe60b42._0x08ff65;
        _0x0eaf30 += _0xc9c74d._0x4571c1();
        _0x0eaf30 -= _0xc9c74d._0x3992b3();
        _0x0eaf30 += _0xe08f87.balance();
        return _0x0eaf30;
    }

    function _0x31243c() external payable _0x69f5d7 {
        emit ReturnsReceived(msg.value);
        _0xcf5665 += msg.value;
    }

    function _0xb9e562() external payable _0x367d07 {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        _0xcf5665 += msg.value;
    }

    modifier _0x69f5d7() {
        if (msg.sender != _0x2ff683) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier _0x367d07() {
        if (msg.sender != address(_0xc9c74d)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier _0x91e4a6() {
        if (msg.sender != address(_0xe08f87)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier _0x91aac1(address _0x4090d2) {
        if (_0x4090d2 == address(0)) {
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