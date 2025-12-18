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

    event Staked(address indexed bv, uint256 bs, uint256 bj);


    event UnstakeRequested(uint256 indexed cl, address indexed bv, uint256 bs, uint256 bg);


    event UnstakeRequestClaimed(uint256 indexed cl, address indexed bv);


    event ValidatorInitiated(bytes32 indexed cl, uint256 indexed bf, bytes bw, uint256 ah);


    event AllocatedETHToUnstakeRequestsManager(uint256 bz);


    event AllocatedETHToDeposits(uint256 bz);


    event ReturnsReceived(uint256 bz);


    event ReturnsReceivedFromLiquidityBuffer(uint256 bz);


    event AllocatedETHToLiquidityBuffer(uint256 bz);
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
    error StakeBelowMinimumMETHAmount(uint256 bk, uint256 ag);
    error UnstakeBelowMinimumETHAmount(uint256 bs, uint256 ag);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = bn("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = bn("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = bn("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = bn("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = bn("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = bn("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 bf;
        uint256 aw;
        bytes bw;
        bytes p;
        bytes bp;
        bytes32 ak;
    }

    mapping(bytes bw => bool cb) public at;
    uint256 public f;
    uint256 public o;
    uint256 public ar;
    uint256 public l;
    uint256 public ab;
    uint256 public w;
    uint16 public n;
    uint16 internal constant h = 10_000;
    uint16 internal constant d = h / 10;
    uint256 public s;
    uint256 public t;
    IDepositContract public al;
    IMETH public cj;
    IOracleReadRecord public by;
    IPauserRead public bx;
    IUnstakeRequestsManager public m;
    address public ae;
    address public aa;
    bool public x;
    uint256 public i;
    uint256 public z;
    ILiquidityBuffer public ai;

    struct Init {
        address cf;
        address bu;
        address ac;
        address ad;
        address aa;
        address ae;
        IMETH cj;
        IDepositContract al;
        IOracleReadRecord by;
        IPauserRead bx;
        IUnstakeRequestsManager m;
    }

    constructor() {
        r();
    }

    function bi(Init memory ch) external bc {
        __AccessControlEnumerable_init();

        be(DEFAULT_ADMIN_ROLE, ch.cf);
        be(STAKING_MANAGER_ROLE, ch.bu);
        be(ALLOCATOR_SERVICE_ROLE, ch.ac);
        be(INITIATOR_SERVICE_ROLE, ch.ad);

        av(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        av(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        cj = ch.cj;
        al = ch.al;
        by = ch.by;
        bx = ch.bx;
        aa = ch.aa;
        m = ch.m;
        ae = ch.ae;

        ab = 0.1 ether;
        w = 0.01 ether;
        s = 32 ether;
        t = 32 ether;
        x = true;
        i = block.number;
        z = 1024 ether;
    }

    function ay(ILiquidityBuffer cm) public ax(2) {
        ai = cm;
    }

    function cg(uint256 au) external payable {
        if (bx.an()) {
            revert Paused();
        }

        if (x) {
            bl(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < ab) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 ao = bm(msg.value);
        if (ao + cj.bd() > z) {
            revert MaximumMETHSupplyExceeded();
        }
        if (ao < au) {
            revert StakeBelowMinimumMETHAmount(ao, au);
        }

        ar += msg.value;

        emit Staked(msg.sender, msg.value, ao);
        cj.ci(msg.sender, ao);
    }

    function as(uint128 bk, uint128 ba) external returns (uint256) {
        return am(bk, ba);
    }

    function j(
        uint128 bk,
        uint128 ba,
        uint256 bt,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable.bh(cj, msg.sender, address(this), bk, bt, v, r, s);
        return am(bk, ba);
    }

    function am(uint128 bk, uint128 ba) internal returns (uint256) {
        if (bx.b()) {
            revert Paused();
        }

        if (bk < w) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 bs = uint128(bo(bk));
        if (bs < ba) {
            revert UnstakeBelowMinimumETHAmount(bs, ba);
        }

        uint256 br =
            m.cc({bq: msg.sender, bg: bk, bb: bs});
        emit UnstakeRequested({cl: br, bv: msg.sender, bs: bs, bg: bk});

        SafeERC20Upgradeable.af(cj, msg.sender, address(m), bk);

        return br;
    }

    function bm(uint256 bs) public view returns (uint256) {
        if (cj.bd() == 0) {
            return bs;
        }
        uint256 k = Math.cd(
            aj(), h + n, h
        );
        return Math.cd(bs, cj.bd(), k);
    }

    function bo(uint256 bj) public view returns (uint256) {
        if (cj.bd() == 0) {
            return bj;
        }
        return Math.cd(bj, aj(), cj.bd());
    }

    function aj() public view returns (uint256) {
        OracleRecord memory ca = by.az();
        uint256 ce = 0;
        ce += ar;
        ce += l;
        ce += f - ca.c;
        ce += ca.e;
        ce += ai.v();
        ce -= ai.y();
        ce += m.balance();
        return ce;
    }

    function aq() external payable q {
        emit ReturnsReceived(msg.value);
        ar += msg.value;
    }

    function a() external payable u {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        ar += msg.value;
    }

    modifier q() {
        if (msg.sender != aa) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier u() {
        if (msg.sender != address(ai)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier g() {
        if (msg.sender != address(m)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier ap(address ck) {
        if (ck == address(0)) {
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