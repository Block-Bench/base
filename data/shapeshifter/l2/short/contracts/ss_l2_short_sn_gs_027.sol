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
    event Staked(address indexed cd, uint256 bs, uint256 bh);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnstakeRequested(uint256 indexed cl, address indexed cd, uint256 bs, uint256 bg);

    /// @notice Emitted when a user claims their unstake request.
    event UnstakeRequestClaimed(uint256 indexed cl, address indexed cd);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed cl, uint256 indexed bl, bytes bz, uint256 an);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedETHToUnstakeRequestsManager(uint256 cb);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 cb);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 cb);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromLiquidityBuffer(uint256 cb);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedETHToLiquidityBuffer(uint256 cb);
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
    error StakeBelowMinimumMETHAmount(uint256 bj, uint256 ai);
    error UnstakeBelowMinimumETHAmount(uint256 bs, uint256 ai);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant STAKING_MANAGER_ROLE = bm("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = bm("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = bm("INITIATOR_SERVICE_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_MANAGER_ROLE = bm("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = bm("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = bm("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 bl;
        uint256 ax;
        bytes bz;
        bytes p;
        bytes bp;
        bytes32 ak;
    }

    mapping(bytes bz => bool bx) public at;
    uint256 public g;
    uint256 public n;
    uint256 public ao;
    uint256 public l;
    uint256 public ab;
    uint256 public u;
    uint16 public o;
    uint16 internal constant i = 10_000;
    uint16 internal constant d = i / 10;
    uint256 public r;
    uint256 public s;
    IDepositContract public am;
    IMETH public cj;
    IOracleReadRecord public by;
    IPauserRead public bv;
    IUnstakeRequestsManager public m;
    address public ac;
    address public aa;
    bool public x;
    uint256 public h;
    uint256 public z;
    ILiquidityBuffer public ah;

    struct Init {
        address ce;
        address bu;
        address ae;
        address af;
        address aa;
        address ac;
        IMETH cj;
        IDepositContract am;
        IOracleReadRecord by;
        IPauserRead bv;
        IUnstakeRequestsManager m;
    }

    constructor() {
        t();
    }

    function bf(Init memory ck) external bd {
        __AccessControlEnumerable_init();

        bi(DEFAULT_ADMIN_ROLE, ck.ce);
        bi(STAKING_MANAGER_ROLE, ck.bu);
        bi(ALLOCATOR_SERVICE_ROLE, ck.ae);
        bi(INITIATOR_SERVICE_ROLE, ck.af);

        av(STAKING_ALLOWLIST_MANAGER_ROLE, STAKING_MANAGER_ROLE);
        av(STAKING_ALLOWLIST_ROLE, STAKING_ALLOWLIST_MANAGER_ROLE);

        cj = ck.cj;
        am = ck.am;
        by = ck.by;
        bv = ck.bv;
        aa = ck.aa;
        m = ck.m;
        ac = ck.ac;

        ab = 0.1 ether;
        u = 0.01 ether;
        r = 32 ether;
        s = 32 ether;
        x = true;
        h = block.number;
        z = 1024 ether;
    }

    function az(ILiquidityBuffer cm) public aw(2) {
        ah = cm;
    }

    function cf(uint256 au) external payable {
        if (bv.al()) {
            revert Paused();
        }

        if (x) {
            bk(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < ab) {
            revert MinimumStakeBoundNotSatisfied();
        }

        uint256 ap = bo(msg.value);
        if (ap + cj.bc() > z) {
            revert MaximumMETHSupplyExceeded();
        }
        if (ap < au) {
            revert StakeBelowMinimumMETHAmount(ap, au);
        }

        ao += msg.value;

        emit Staked(msg.sender, msg.value, ap);
        cj.ci(msg.sender, ap);
    }

    function as(uint128 bj, uint128 ba) external returns (uint256) {
        return ag(bj, ba);
    }

    function j(
        uint128 bj,
        uint128 ba,
        uint256 bt,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable.be(cj, msg.sender, address(this), bj, bt, v, r, s);
        return ag(bj, ba);
    }

    function ag(uint128 bj, uint128 ba) internal returns (uint256) {
        if (bv.b()) {
            revert Paused();
        }

        if (bj < u) {
            revert MinimumUnstakeBoundNotSatisfied();
        }

        uint128 bs = uint128(bq(bj));
        if (bs < ba) {
            revert UnstakeBelowMinimumETHAmount(bs, ba);
        }

        uint256 bn =
            m.bw({br: msg.sender, bg: bj, ay: bs});
        emit UnstakeRequested({cl: bn, cd: msg.sender, bs: bs, bg: bj});

        SafeERC20Upgradeable.ad(cj, msg.sender, address(m), bj);

        return bn;
    }

    function bo(uint256 bs) public view returns (uint256) {
        if (cj.bc() == 0) {
            return bs;
        }
        uint256 k = Math.cc(
            aj(), i + o, i
        );
        return Math.cc(bs, cj.bc(), k);
    }

    function bq(uint256 bh) public view returns (uint256) {
        if (cj.bc() == 0) {
            return bh;
        }
        return Math.cc(bh, aj(), cj.bc());
    }

    function aj() public view returns (uint256) {
        OracleRecord memory ca = by.bb();
        uint256 cg = 0;
        cg += ao;
        cg += l;
        cg += g - ca.c;
        cg += ca.e;
        cg += ah.w();
        cg -= ah.y();
        cg += m.balance();
        return cg;
    }

    function aq() external payable q {
        emit ReturnsReceived(msg.value);
        ao += msg.value;
    }

    function a() external payable v {
        emit ReturnsReceivedFromLiquidityBuffer(msg.value);
        ao += msg.value;
    }

    modifier q() {
        if (msg.sender != aa) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier v() {
        if (msg.sender != address(ah)) {
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

    modifier ar(address ch) {
        if (ch == address(0)) {
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