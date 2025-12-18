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

    event Staked(address indexed bx, uint256 bp, uint256 bf);


    event UnstakeRequested(uint256 indexed cl, address indexed bx, uint256 bp, uint256 be);


    event UnstakeRequestClaimed(uint256 indexed cl, address indexed bx);


    event ValidatorInitiated(bytes32 indexed cl, uint256 indexed bg, bytes cb, uint256 ak);


    event AllocatedETHToUnstakeRequestsManager(uint256 bv);


    event AllocatedETHToDeposits(uint256 bv);


    event ReturnsReceived(uint256 bv);


    event ReturnsReceivedFromLiquidityBuffer(uint256 bv);


    event AllocatedETHToLiquidityBuffer(uint256 bv);
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
    error StakeBelowMinimumMETHAmount(uint256 bj, uint256 ai);
    error UnstakeBelowMinimumETHAmount(uint256 bp, uint256 ai);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = bq("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = bq("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = bq("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = bq("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = bq("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = bq("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 bg;
        uint256 av;
        bytes cb;
        bytes q;
        bytes bn;
        bytes32 ag;
    }

    mapping(bytes cb => bool cd) public at;
    uint256 public g;
    uint256 public n;
    uint256 public ar;
    uint256 public l;
    uint256 public aa;
    uint256 public v;
    uint16 public o;
    uint16 internal constant h = 10_000;
    uint16 internal constant d = h / 10;
    uint256 public r;
    uint256 public s;
    IDepositContract public al;
    IMETH public ci;
    IOracleReadRecord public by;
    IPauserRead public cc;
    IUnstakeRequestsManager public m;
    address public ad;
    address public ab;
    bool public y;
    uint256 public i;
    uint256 public z;
    ILiquidityBuffer public am;

    struct Init {
        address ce;
        address bu;
        address ac;
        address af;
        address ab;
        address ad;
        IMETH ci;
        IDepositContract al;
        IOracleReadRecord by;
        IPauserRead cc;
        IUnstakeRequestsManager m;
    }

    constructor() {
        t();
    }

    function bk(Init memory ch) external bd {
        __AccessControlEnumerable_init();

        bl(DEFAULT_ADMIN_ROLE, ch.ce);
        bl(STAKING_MANAGER_ROLE, ch.bu);
        bl(ALLOCATOR_SERVICE_ROLE, ch.ac);
        bl(INITIATOR_SERVICE_ROLE, ch.af);

        ax(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        ax(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        ci = ch.ci;
        al = ch.al;
        by = ch.by;
        cc = ch.cc;
        ab = ch.ab;
        m = ch.m;
        ad = ch.ad;

        aa = 0.1 ether;
        v = 0.01 ether;
        r = 32 ether;
        s = 32 ether;
        y = true;
        i = block.number;
        z = 1024 ether;
    }

    function ay(ILiquidityBuffer cm) public au(2) {
        am = cm;
    }

    function cg(uint256 aw) external payable {
        if (cc.ah()) {
            revert Paused();
        }

        if (y) {
            bi(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < aa) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 as = bs(msg.value);
        if (as + ci.bc() > z) {
            revert MaximumMETHSupplyExceeded();
        }
        if (as < aw) {
            revert StakeBelowMinimumMETHAmount(as, aw);
        }

        ar += msg.value;

        emit Staked(msg.sender, msg.value, as);
        ci.cj(msg.sender, as);
    }

    function ap(uint128 bj, uint128 az) external returns (uint256) {
        return aj(bj, az);
    }

    function j(
        uint128 bj,
        uint128 az,
        uint256 bt,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable.bh(ci, msg.sender, address(this), bj, bt, v, r, s);
        return aj(bj, az);
    }

    function aj(uint128 bj, uint128 az) internal returns (uint256) {
        if (cc.b()) {
            revert Paused();
        }

        if (bj < v) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 bp = uint128(br(bj));
        if (bp < az) {
            revert UnstakeBelowMinimumETHAmount(bp, az);
        }

        uint256 bm =
            m.bw({bo: msg.sender, be: bj, bb: bp});
        emit UnstakeRequested({cl: bm, bx: msg.sender, bp: bp, be: bj});

        SafeERC20Upgradeable.ae(ci, msg.sender, address(m), bj);

        return bm;
    }

    function bs(uint256 bp) public view returns (uint256) {
        if (ci.bc() == 0) {
            return bp;
        }
        uint256 k = Math.bz(
            an(), h + o, h
        );
        return Math.bz(bp, ci.bc(), k);
    }

    function br(uint256 bf) public view returns (uint256) {
        if (ci.bc() == 0) {
            return bf;
        }
        return Math.bz(bf, an(), ci.bc());
    }

    function an() public view returns (uint256) {
        OracleRecord memory ca = by.ba();
        uint256 cf = 0;
        cf += ar;
        cf += l;
        cf += g - ca.c;
        cf += ca.e;
        cf += am.u();
        cf -= am.x();
        cf += m.balance();
        return cf;
    }

    function aq() external payable p {
        emit ReturnsReceived(msg.value);
        ar += msg.value;
    }

    function a() external payable w {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        ar += msg.value;
    }

    modifier p() {
        if (msg.sender != ab) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier w() {
        if (msg.sender != address(am)) {
            revert NotLiquidityBuffer();
        }
        _;
    }

    modifier f() {
        if (msg.sender != address(m)) {
            revert NotUnstakeRequestsManager();
        }
        _;
    }

    modifier ao(address ck) {
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